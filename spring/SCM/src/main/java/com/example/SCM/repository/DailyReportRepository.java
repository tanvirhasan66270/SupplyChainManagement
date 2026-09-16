package com.example.SCM.repository;

import com.example.SCM.entity.DailyReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface DailyReportRepository extends JpaRepository<DailyReport, Long> {
    List<DailyReport> findByWarehouseIdOrderByReportDateDesc(String warehouseId);
    boolean existsByWarehouseIdAndReportDate(String warehouseId, LocalDate reportDate);
}