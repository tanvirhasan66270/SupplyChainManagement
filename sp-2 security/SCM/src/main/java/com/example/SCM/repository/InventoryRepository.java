package com.example.SCM.repository;

import com.example.SCM.entity.Inventory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {

      Optional<Inventory> findByProductIdAndWarehouseId(Long productId, Long warehouseId);

    List<Inventory> findByWarehouseId(Long warehouseId);

    List<Inventory> findByProductId(Long productId);

    List<Inventory> findByStockStatus(String stockStatus);

    @Query("SELECT i FROM Inventory i WHERE i.warehouse.policeStation.district.name = :districtName")
    List<Inventory> findByWarehouseDistrictName(@Param("districtName") String districtName);


    @Query("SELECT i FROM Inventory i WHERE i.expiryDate IS NOT NULL AND i.expiryDate <= CURRENT_DATE")
    List<Inventory> findExpiredInventories();
}