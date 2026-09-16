package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.InventoryRequestDTO;
import com.example.SCM.dto.response.InventoryResponseDTO;
import com.example.SCM.entity.Inventory;
import com.example.SCM.entity.Product;
import com.example.SCM.entity.Warehouse;
import com.example.SCM.enumClass.StockStatus; // 🎯 কাস্টম এনাম প্যাকেজ ইমপোর্ট
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Component
public class InventoryMapper {

    private final DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public Inventory toEntity(InventoryRequestDTO dto, Product product, Warehouse warehouse) {
        if (dto == null) return null;

        Inventory inventory = new Inventory();
        inventory.setQuantityOnHand(dto.getQuantityOnHand());
        inventory.setQuantityReserved(dto.getQuantityReserved());
        inventory.setLocationStatus(dto.getLocationStatus());

        if (dto.getStockStatus() != null && !dto.getStockStatus().trim().isEmpty()) {
            inventory.setStockStatus(StockStatus.valueOf(dto.getStockStatus().toUpperCase()));
        } else {
            inventory.setStockStatus(StockStatus.IN_STOCK); // Fallback Default
        }

        if (dto.getExpiryDate() != null && !dto.getExpiryDate().trim().isEmpty()) {
            inventory.setExpiryDate(LocalDate.parse(dto.getExpiryDate(), dateFormatter));
        }

        inventory.setProduct(product);
        inventory.setWarehouse(warehouse);

        return inventory;
    }

    public InventoryResponseDTO convertTOResponseDTO(Inventory inventory) {
        if (inventory == null) return null;

        InventoryResponseDTO dto = new InventoryResponseDTO();
        dto.setId(inventory.getId());
        dto.setQuantityOnHand(inventory.getQuantityOnHand());
        dto.setQuantityReserved(inventory.getQuantityReserved());
        dto.setLocationStatus(inventory.getLocationStatus());
        dto.setExpiryDate(inventory.getExpiryDate());
        dto.setLastUpdated(inventory.getLastUpdated());

        dto.setStockStatus(inventory.getStockStatus() != null ? inventory.getStockStatus().name() : null);

        int available = inventory.getQuantityOnHand() - inventory.getQuantityReserved();
        dto.setAvailableQuantity(Math.max(available, 0));

        if (inventory.getProduct() != null) {
            Product prod = inventory.getProduct();
            dto.setProductId(prod.getId());
            dto.setProductCode(prod.getProductCode());
            dto.setProductName(prod.getName());
        }

        if (inventory.getWarehouse() != null) {
            Warehouse wh = inventory.getWarehouse();
            dto.setWarehouseId(wh.getId());
            dto.setWarehouseName(wh.getName());
        }

        return dto;
    }

    public void updateEntity(InventoryRequestDTO dto, Inventory inventory, Product product, Warehouse warehouse) {
        if (dto == null || inventory == null) return;

        inventory.setQuantityOnHand(dto.getQuantityOnHand());
        inventory.setQuantityReserved(dto.getQuantityReserved());

        if (dto.getLocationStatus() != null) {
            inventory.setLocationStatus(dto.getLocationStatus());
        }

        if (dto.getStockStatus() != null && !dto.getStockStatus().trim().isEmpty()) {
            inventory.setStockStatus(StockStatus.valueOf(dto.getStockStatus().toUpperCase()));
        }

        if (dto.getExpiryDate() != null && !dto.getExpiryDate().trim().isEmpty()) {
            inventory.setExpiryDate(LocalDate.parse(dto.getExpiryDate(), dateFormatter));
        }

        if (product != null) inventory.setProduct(product);
        if (warehouse != null) inventory.setWarehouse(warehouse);
    }
}