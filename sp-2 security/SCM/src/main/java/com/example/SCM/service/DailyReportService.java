package com.example.SCM.service;

import com.example.SCM.dto.request.DailyReportRequestDTO;
import com.example.SCM.dto.response.DailyReportResponseDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Optional;

public interface DailyReportService {
    DailyReportResponseDTO save(DailyReportRequestDTO dto, MultipartFile file);
    DailyReportResponseDTO update(Long id, DailyReportRequestDTO dto,MultipartFile file);
    DailyReportResponseDTO approveReport(Long id, String approvedByUserId); // ডাইনামিক অ্যাপ্রুভাল নোড
    List<DailyReportResponseDTO> findAll();
    Optional<DailyReportResponseDTO> getById(Long id);
    List<DailyReportResponseDTO> getByWarehouse(String warehouseId);
    void delete(Long id);
}