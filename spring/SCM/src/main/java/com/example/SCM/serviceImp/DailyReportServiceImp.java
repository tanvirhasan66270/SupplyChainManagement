package com.example.SCM.serviceImp;

import com.example.SCM.Util.MailService;
import com.example.SCM.dto.mapper.DailyReportMapper;
import com.example.SCM.dto.request.DailyReportRequestDTO;
import com.example.SCM.dto.response.DailyReportResponseDTO;
import com.example.SCM.entity.DailyReport;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.enumClass.ReportStatus;
import com.example.SCM.role.Role;
import com.example.SCM.repository.DailyReportRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.service.DailyReportService;
import com.example.SCM.service.ActivityLogService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DailyReportServiceImp implements DailyReportService {

    private final DailyReportRepository reportRepository;
    private final DailyReportMapper reportMapper;
    private final MailService mailService;
    private final ActivityLogService activityLogService;
    private final UserRepository userRepository;
    private final HttpServletRequest request;

    @Value("${image.upload.dir}")
    private String uploadDir;

    private String resolveCurrentUserId() {
        String userId = request.getHeader("X-User-Id");
        if (userId != null && !userId.isBlank()) {
            return userId;
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !authentication.getName().equals("anonymousUser")) {
            return authentication.getName();
        }
        return "UNKNOWN_USER";
    }

    @Transactional
    @Override
    public DailyReportResponseDTO save(DailyReportRequestDTO dto, MultipartFile file) {

        LocalDate rDate = LocalDate.parse(dto.getReportDate());
        if (reportRepository.existsByWarehouseIdAndReportDate(dto.getWarehouseId(), rDate)) {
            throw new RuntimeException("Daily Report already logged for this warehouse on date: " + dto.getReportDate());
        }

        DailyReport report = reportMapper.toEntity(dto);
        report.setUserId(resolveCurrentUserId());
        report.setReportStatus(ReportStatus.DRAFT);

        if (file != null && !file.isEmpty()) {
            String savedFileName = uploadFile(file, "reports");
            report.setAttachmentUrl(savedFileName);
        }

        DailyReport savedReport = reportRepository.save(report);
        List<Map<String, String>> notifiedList = sendReportToManagersAndAdmins(savedReport);

        if (notifiedList != null && !notifiedList.isEmpty()) {
            savedReport.setReportStatus(ReportStatus.SUBMITTED);
            savedReport = reportRepository.save(savedReport);
        }

        DailyReportResponseDTO responseDTO = reportMapper.convertTOResponseDTO(savedReport);
        responseDTO.setNotifiedAuthorities(notifiedList);

        activityLogService.log(
                resolveCurrentUserId(), null, "CREATE", "DAILY_REPORT",
                savedReport.getId().toString(),
                "Logistics Officer generated daily operational report for Node: " + savedReport.getWarehouseId(),
                null, savedReport.getReportStatus().toString(), ActionStatus.SUCCESS, request.getRemoteAddr()
        );

        return responseDTO;
    }

    @Transactional
    @Override
    public DailyReportResponseDTO update(Long id, DailyReportRequestDTO dto, MultipartFile file) {
        DailyReport report = reportRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Report index missing for ID: " + id));

        if (report.getReportStatus() == ReportStatus.APPROVED) {
            throw new RuntimeException("Locked! Approved records cannot be updated.");
        }

        String oldSummary = report.getSummary();

        if (dto.getSummary() != null) report.setSummary(dto.getSummary());
        if (dto.getTotalTasksDone() > 0) report.setTotalTasksDone(dto.getTotalTasksDone());
        if (dto.getIssuesLogged() >= 0) report.setIssuesLogged(dto.getIssuesLogged());

        if (file != null && !file.isEmpty()) {
            String savedFileName = uploadFile(file, "reports");
            report.setAttachmentUrl(savedFileName);
        }

        DailyReport updatedReport = reportRepository.save(report);
        DailyReportResponseDTO responseDTO = reportMapper.convertTOResponseDTO(updatedReport);

        activityLogService.log(
                resolveCurrentUserId(), null, "UPDATE", "DAILY_REPORT",
                updatedReport.getId().toString(),
                "Daily report parameters modified for Node: " + updatedReport.getWarehouseId(),
                "{\"summary\":\"" + oldSummary + "\"}", "{\"summary\":\"" + updatedReport.getSummary() + "\"}",
                ActionStatus.SUCCESS, request.getRemoteAddr()
        );

        return responseDTO;
    }

    @Transactional
    @Override
    public DailyReportResponseDTO approveReport(Long id, String approvedByUserId) {
        DailyReport report = reportRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Daily Report missing for ID: " + id));

        report.setReportStatus(ReportStatus.APPROVED);
        DailyReport approvedReport = reportRepository.save(report);

        String finalApprover = (approvedByUserId != null) ? approvedByUserId : resolveCurrentUserId();

        activityLogService.log(
                finalApprover, null, "APPROVE", "DAILY_REPORT",
                approvedReport.getId().toString(),
                "Report officially APPROVED via Manager Gateway for Warehouse: " + approvedReport.getWarehouseId(),
                "{\"status\":\"SUBMITTED\"}", "{\"status\":\"APPROVED\"}", ActionStatus.SUCCESS, request.getRemoteAddr()
        );

        return reportMapper.convertTOResponseDTO(approvedReport);
    }

    private List<Map<String, String>> sendReportToManagersAndAdmins(DailyReport report) {
        List<Map<String, String>> successfullyNotified = new ArrayList<>();
        List<Role> targetRoles = List.of(Role.MANAGER, Role.ADMIN);
        List<User> targetUsers = userRepository.findUsersByRoles(targetRoles);

        if (targetUsers == null || targetUsers.isEmpty()) {
            return successfullyNotified;
        }

        String subject = "SCM Monitoring Alert: Daily Operational Report - " + report.getWarehouseId();

        for (User user : targetUsers) {
            try {
                if (user.getEmail() != null) {
                    String approvalUrl = "http://localhost:8085/api/reports/email-approve?id=" + report.getId() + "&approverId=" + user.getId();
                    String fileDownloadUrl = report.getAttachmentUrl() != null ? "http://localhost:8085/" + report.getAttachmentUrl() : "#";

                    String mailContent = """
                    <!DOCTYPE html>
                    <html>
                    <head>
                        <style>
                            body { font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #2D3748; }
                            .container { max-width: 650px; margin: 20px auto; border: 1px solid #E2E8F0; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
                            .header { background-color: #2C5282; color: white; padding: 25px; text-align: center; }
                            .status-badge { display: inline-block; padding: 6px 16px; font-weight: bold; border-radius: 20px; font-size: 13px; text-transform: uppercase; background-color: #EBF8FF; color: #2B6CB0; }
                            .content { padding: 30px; background-color: #ffffff; }
                            .info-grid { width: 100%%; margin: 20px 0; border-collapse: collapse; }
                            .info-grid td { padding: 12px; border-bottom: 1px solid #EDF2F7; font-size: 14px; }
                            .info-grid td.label { font-weight: bold; color: #4A5568; width: 35%%; }
                            .summary-box { background-color: #F7FAFC; border-left: 4px solid #2C5282; padding: 15px; margin-top: 15px; font-style: italic; border-radius: 0 4px 4px 0; }
                            .approve-btn-container { text-align: center; margin: 30px 0 10px 0; }
                            .approve-btn { background-color: #38A169; color: white !important; padding: 12px 35px; font-weight: bold; text-decoration: none; border-radius: 6px; display: inline-block; box-shadow: 0 4px 6px rgba(56,161,105,0.2); font-size: 15px; }
                            .footer { background-color: #F7FAFC; padding: 20px; text-align: center; font-size: 12px; color: #718096; border-top: 1px solid #EDF2F7; }
                        </style>
                    </head>
                    <body>
                        <div class='container'>
                            <div class='header'>
                                <h2 style='margin:0 0 10px 0;'>Logistics Activity EOD Report</h2>
                                <div class='status-badge'>Status: PENDING ROUTING</div>
                            </div>
                            <div class='content'>
                                <p>Dear <b>%s</b>,</p>
                                <p>This is an automated system dispatch containing the day-end operational overview logged by the assigned Logistics Officer.</p>
                                
                                <table class='info-grid'>
                                    <tr><td class='label'>Logistics Officer ID:</td><td><b>%s</b></td></tr>
                                    <tr><td class='label'>Warehouse Node:</td><td>%s</td></tr>
                                    <tr><td class='label'>Operation Date:</td><td><b>%s</b></td></tr>
                                    <tr><td class='label'>Total Tasks Processed:</td><td><span style='color:#2B6CB0; font-weight:bold;'>%d Transactions</span></td></tr>
                                    <tr><td class='label'>Issues / Damages Logged:</td><td><span style='color:#C53030; font-weight:bold;'>%d Counter(s)</span></td></tr>
                                    <tr><td class='label'>Attachment Vault:</td><td><a href='%s' style='color:#2B6CB0; font-weight:bold;'>View Uploaded Image Proof</a></td></tr>
                                </table>
                                
                                <h4 style='margin-bottom:5px; color:#4A5568;'>Operational Summary Notes:</h4>
                                <div class='summary-box'>"%s"</div>
                                
                                <div class='approve-btn-container'>
                                    <a href='%s' class='approve-btn'>✔ APPROVE THIS REPORT</a>
                                </div>
                            </div>
                            <div class='footer'>&copy; SCM Global Sourcing Network. All rights reserved.</div>
                        </div>
                    </body>
                    </html>
                    """.formatted(
                            user.getName(), report.getUserId(), report.getWarehouseId(),
                            report.getReportDate().toString(), report.getTotalTasksDone(), report.getIssuesLogged(),
                            fileDownloadUrl, report.getSummary(), approvalUrl
                    );

                    mailService.senderGeneralMail(user.getEmail(), subject, mailContent);

                    Map<String, String> authorityInfo = Map.of(
                            "name", user.getName(),
                            "email", user.getEmail(),
                            "role", user.getRole().name()
                    );
                    successfullyNotified.add(authorityInfo);
                }
            } catch (Exception e) {
                System.err.println("Skipping failed mail route: " + user.getEmail());
            }
        }
        return successfullyNotified;
    }

    private String uploadFile(MultipartFile file, String subFolder) {
        try {
            Path path = Paths.get(uploadDir, subFolder);
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = subFolder.toUpperCase();
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Report file syncing operational exception: " + e.getMessage());
        }
    }

    @Transactional(readOnly = true)
    @Override
    public List<DailyReportResponseDTO> findAll() { return reportRepository.findAll().stream().map(reportMapper::convertTOResponseDTO).collect(Collectors.toList()); }

    @Transactional(readOnly = true)
    @Override
    public Optional<DailyReportResponseDTO> getById(Long id) { return reportRepository.findById(id).map(reportMapper::convertTOResponseDTO); }

    @Transactional(readOnly = true)
    @Override
    public List<DailyReportResponseDTO> getByWarehouse(String warehouseId) { return reportRepository.findByWarehouseIdOrderByReportDateDesc(warehouseId).stream().map(reportMapper::convertTOResponseDTO).collect(Collectors.toList()); }

    @Transactional
    @Override
    public void delete(Long id) { reportRepository.deleteById(id); }
}