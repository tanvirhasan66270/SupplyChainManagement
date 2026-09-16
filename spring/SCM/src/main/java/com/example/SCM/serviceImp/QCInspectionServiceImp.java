package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.QCInspectionMapper;
import com.example.SCM.dto.request.QCInspectionRequestDTO;
import com.example.SCM.dto.request.QCChecklistRequestDTO;
import com.example.SCM.dto.response.QCInspectionResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.repository.*;
import com.example.SCM.service.ActivityLogService;
import com.example.SCM.service.QCInspectionService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.*;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import com.example.SCM.service.NotificationService;
import com.example.SCM.role.Role;

@Service
@RequiredArgsConstructor
public class QCInspectionServiceImp implements QCInspectionService {

    private final QCInspectionRepository qcInspectionRepository;
    private final GoodsReceivedNoteRepository goodsReceivedNoteRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final QCInspectionMapper qcInspectionMapper;
    private final NotificationService notificationService;

    // Activity Log & Request Context Dependencies
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;

    @Value("${image.upload.dir}")
    private String uploadDir;

    // Dynamically resolves current active user or system actor

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
        return "SYSTEM_AUTOMATION";
    }

    @Override
    @Transactional
    public QCInspectionResponseDTO save(QCInspectionRequestDTO dto, MultipartFile file) {
        GoodsReceivedNote grn = goodsReceivedNoteRepository.findById(dto.getGrnId()).orElseThrow(() -> new RuntimeException("GRN not found"));
        Product product = productRepository.findById(dto.getProductId()).orElseThrow(() -> new RuntimeException("Product not found"));
        User inspector = userRepository.findById(dto.getInspectedBy()).orElseThrow(() -> new RuntimeException("Inspector not found"));

        QCInspection inspection = qcInspectionMapper.toEntity(dto, grn, product, inspector);

        if (dto.getChecklists() != null && !dto.getChecklists().isEmpty()) {
            for (QCChecklistRequestDTO cDto : dto.getChecklists()) {
                QCChecklist chk = new QCChecklist();
                chk.setCheckpointName(cDto.getCheckpointName());
                chk.setPassed(cDto.isPassed());
                chk.setRemarks(cDto.getRemarks());

                chk.setQcInspection(inspection);
                inspection.getChecklists().add(chk);
            }
        }

        if (file != null && !file.isEmpty()) {
            inspection.setLabTestReport(uploadLabReport(file, dto.getInspectionType()));
        }

        QCInspection saved = qcInspectionRepository.saveAndFlush(inspection);

        try {
            String title = "New QC Inspection Created: #" + saved.getId();
            String message = String.format(
                    "New QC Inspection (%s) performed for GRN #%s, Product: %s. Result: %s (Defects: %d/%d).",
                    saved.getInspectionType(),
                    grn.getGrnNumber() != null ? grn.getGrnNumber() : grn.getId().toString(),
                    product.getName() != null ? product.getName() : product.getId().toString(),
                    saved.getResult() != null ? saved.getResult().toString() : "N/A",
                    saved.getDefectsFound(),
                    saved.getSampleSize()
            );

            // 1. Dispatch to role-level targets
            notificationService.send("LOGISTICS_OFFICER", "QC_INSPECTION", title, message);
            notificationService.send("MANAGER", "QC_INSPECTION", title, message);

            // 2. Dispatch to specific user IDs
            List<Role> targetRoles = List.of(Role.LOGISTICS_OFFICER, Role.MANAGER);
            List<User> targetUsers = userRepository.findUsersByRoles(targetRoles);
            if (targetUsers != null) {
                for (User user : targetUsers) {
                    if (user.getId() != null) {
                        notificationService.send(
                                user.getId().toString(),
                                "QC_INSPECTION",
                                title,
                                message
                        );
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("QC Inspection Notification Error: " + e.getMessage());
        }

        //  ACTIVITY LOG: CREATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "CREATE",
                "QC_INSPECTION",
                saved.getId().toString(),
                "Quality Control Inspection created for Product ID: " + product.getId() + " by Inspector ID: " + inspector.getId(),
                null,
                "{\"inspectionType\":\"" + saved.getInspectionType() + "\", \"grnId\":" + grn.getId() + "}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return qcInspectionMapper.convertTOResponseDTO(saved);
    }

    @Override
    @Transactional
    public QCInspectionResponseDTO update(Long id, QCInspectionRequestDTO dto, MultipartFile file) {
        QCInspection inspection = qcInspectionRepository.findById(id).orElseThrow(() -> new RuntimeException("QC Record not found"));

        String oldType = inspection.getInspectionType();

        GoodsReceivedNote grn = goodsReceivedNoteRepository.findById(dto.getGrnId()).orElse(inspection.getGoodsReceivedNote());
        Product product = productRepository.findById(dto.getProductId()).orElse(inspection.getProduct());
        User inspector = userRepository.findById(dto.getInspectedBy()).orElse(inspection.getInspectedBy());

        qcInspectionMapper.updateEntity(dto, inspection, grn, product, inspector);

        if (dto.getChecklists() != null) {
            inspection.getChecklists().clear();
            for (QCChecklistRequestDTO cDto : dto.getChecklists()) {
                QCChecklist chk = new QCChecklist();
                chk.setCheckpointName(cDto.getCheckpointName());
                chk.setPassed(cDto.isPassed());
                chk.setRemarks(cDto.getRemarks());
                chk.setQcInspection(inspection);
                inspection.getChecklists().add(chk);
            }
        }

        if (file != null && !file.isEmpty()) {
            inspection.setLabTestReport(uploadLabReport(file, dto.getInspectionType()));
        }

        QCInspection updated = qcInspectionRepository.saveAndFlush(inspection);

        //  ACTIVITY LOG: UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "QC_INSPECTION",
                updated.getId().toString(),
                "QC Inspection record updated for ID: " + updated.getId(),
                "{\"inspectionType\":\"" + oldType + "\"}",
                "{\"inspectionType\":\"" + updated.getInspectionType() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return qcInspectionMapper.convertTOResponseDTO(updated);
    }

    @Override
    @Transactional(readOnly = true)
    public List<QCInspectionResponseDTO> findAll() {
        return qcInspectionRepository.findAllInspectionsWithDetails().stream()
                .map(qcInspectionMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<QCInspectionResponseDTO> getById(Long id) {
        return qcInspectionRepository.findByIdWithDetails(id).map(qcInspectionMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        QCInspection inspection = qcInspectionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("QC record not found"));

        String inspectionType = inspection.getInspectionType();

        qcInspectionRepository.delete(inspection);

        //  ACTIVITY LOG: DELETE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "DELETE",
                "QC_INSPECTION",
                id.toString(),
                "QC Inspection record deleted for ID: " + id,
                "{\"inspectionType\":\"" + inspectionType + "\"}",
                null,
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }

    private String uploadLabReport(MultipartFile file, String inspectionType) {
        try {
            Path path = Paths.get(uploadDir, "qc");
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }
            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }
            String cleanedName = inspectionType != null ? inspectionType.trim().replaceAll("\\s+", "_") : "GENERAL";
            String fileName = "QC_" + cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName));
            return fileName;
        } catch (Exception e) {
            throw new RuntimeException("File upload failed: " + e.getMessage());
        }
    }
}