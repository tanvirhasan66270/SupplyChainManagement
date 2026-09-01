package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.InventoryMapper;
import com.example.SCM.dto.request.InventoryRequestDTO;
import com.example.SCM.dto.response.InventoryResponseDTO;
import com.example.SCM.entity.Inventory;
import com.example.SCM.entity.Product;
import com.example.SCM.entity.Warehouse;
import com.example.SCM.enumClass.ActionStatus;
import com.example.SCM.enumClass.StockStatus;
import com.example.SCM.repository.InventoryRepository;
import com.example.SCM.repository.ProductRepository;
import com.example.SCM.repository.WarehouseRepository;
import com.example.SCM.service.ActivityLogService;
import com.example.SCM.service.InventoryService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class InventoryServiceImp implements InventoryService {

    private final InventoryRepository inventoryRepository;
    private final ProductRepository productRepository;
    private final WarehouseRepository warehouseRepository;
    private final InventoryMapper inventoryMapper;
    private final com.example.SCM.service.NotificationService notificationService;

    // Activity Log & Request Context Dependencies
    private final ActivityLogService activityLogService;
    private final HttpServletRequest request;

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
    public InventoryResponseDTO save(InventoryRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Inventory request data cannot be null");
        }

        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + dto.getProductId()));

        Warehouse warehouse = warehouseRepository.findById(dto.getWarehouseId())
                .orElseThrow(() -> new RuntimeException("Warehouse not found with ID: " + dto.getWarehouseId()));

        Optional<Inventory> existingStock = inventoryRepository.findByProductIdAndWarehouseId(dto.getProductId(), dto.getWarehouseId());
        if (existingStock.isPresent()) {
            Inventory inventory = existingStock.get();
            StockStatus oldStatus = inventory.getStockStatus();
            inventoryMapper.updateEntity(dto, inventory, product, warehouse);
            calculateAndSetStockStatus(inventory, product);
            Inventory updatedInventory = inventoryRepository.saveAndFlush(inventory);
            
            if (updatedInventory.getStockStatus() == StockStatus.LOW_STOCK && oldStatus != StockStatus.LOW_STOCK) {
                notificationService.send("LOGISTICS_OFFICER", "WARNING", "Low Stock Alert", "Stock for product " + product.getName() + " has reached low levels at warehouse " + warehouse.getName());
            }

            activityLogService.log(
                    resolveCurrentUserId(),
                    null,
                    "UPDATE",
                    "INVENTORY",
                    updatedInventory.getId().toString(),
                    "Stock levels auto-adjusted (auto-save fallback) for Product ID: " + product.getId() + " at Warehouse: " + warehouse.getName(),
                    null,
                    "{\"quantityOnHand\":" + updatedInventory.getQuantityOnHand() + ", \"stockStatus\":\"" + updatedInventory.getStockStatus().name() + "\"}",
                    ActionStatus.SUCCESS,
                    request.getRemoteAddr()
            );

            return inventoryMapper.convertTOResponseDTO(updatedInventory);
        }

        Inventory inventory = inventoryMapper.toEntity(dto, product, warehouse);

        calculateAndSetStockStatus(inventory, product);

        Inventory savedInventory = inventoryRepository.saveAndFlush(inventory);
        
        if (savedInventory.getStockStatus() == StockStatus.LOW_STOCK) {
            notificationService.send("LOGISTICS_OFFICER", "WARNING", "Low Stock Alert", "Stock for product " + product.getName() + " is critically low at warehouse " + warehouse.getName());
        }

        //  ACTIVITY LOG: CREATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "CREATE",
                "INVENTORY",
                savedInventory.getId().toString(),
                "Initial inventory stock allocation performed for Product ID: " + product.getId() + " at Warehouse: " + warehouse.getName(),
                null,
                "{\"quantityOnHand\":" + savedInventory.getQuantityOnHand() + ", \"stockStatus\":\"" + savedInventory.getStockStatus().name() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return inventoryMapper.convertTOResponseDTO(savedInventory);
    }

    @Override
    @Transactional
    public InventoryResponseDTO update(Long id, InventoryRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Inventory request data cannot be null");
        }

        Inventory inventory = inventoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inventory record not found with ID: " + id));

        int oldQuantityOnHand = inventory.getQuantityOnHand();
        int oldQuantityReserved = inventory.getQuantityReserved();
        StockStatus oldStatus = inventory.getStockStatus();

        Product product = inventory.getProduct();
        if (dto.getProductId() != null && !dto.getProductId().equals(product.getId())) {
            product = productRepository.findById(dto.getProductId())
                    .orElseThrow(() -> new RuntimeException("New Product not found with ID: " + dto.getProductId()));
        }

        Warehouse warehouse = inventory.getWarehouse();
        if (dto.getWarehouseId() != null && !dto.getWarehouseId().equals(warehouse.getId())) {
            warehouse = warehouseRepository.findById(dto.getWarehouseId())
                    .orElseThrow(() -> new RuntimeException("New Warehouse not found with ID: " + dto.getWarehouseId()));
        }

        inventoryMapper.updateEntity(dto, inventory, product, warehouse);

        calculateAndSetStockStatus(inventory, product);

        Inventory updatedInventory = inventoryRepository.saveAndFlush(inventory);
        
        if (updatedInventory.getStockStatus() == StockStatus.LOW_STOCK && oldStatus != StockStatus.LOW_STOCK) {
            notificationService.send("LOGISTICS_OFFICER", "WARNING", "Low Stock Alert", "Stock for product " + product.getName() + " has reached low levels at warehouse " + warehouse.getName());
        }

        //  ACTIVITY LOG: UPDATE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "UPDATE",
                "INVENTORY",
                updatedInventory.getId().toString(),
                "Stock levels updated for Inventory ID: " + updatedInventory.getId() + " at Warehouse: " + warehouse.getName(),
                "{\"quantityOnHand\":" + oldQuantityOnHand + ", \"quantityReserved\":" + oldQuantityReserved + ", \"stockStatus\":\"" + oldStatus + "\"}",
                "{\"quantityOnHand\":" + updatedInventory.getQuantityOnHand() + ", \"quantityReserved\":" + updatedInventory.getQuantityReserved() + ", \"stockStatus\":\"" + updatedInventory.getStockStatus() + "\"}",
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );

        return inventoryMapper.convertTOResponseDTO(updatedInventory);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InventoryResponseDTO> findAll() {
        return inventoryRepository.findAll().stream()
                .map(inventoryMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<InventoryResponseDTO> getById(Long id) {
        return inventoryRepository.findById(id)
                .map(inventoryMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Inventory inventory = inventoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Inventory record not found with ID: " + id));

        int quantity = inventory.getQuantityOnHand();
        Long productId = inventory.getProduct() != null ? inventory.getProduct().getId() : null;

        inventoryRepository.delete(inventory);

        // ACTIVITY LOG: DELETE
        activityLogService.log(
                resolveCurrentUserId(),
                null,
                "DELETE",
                "INVENTORY",
                id.toString(),
                "Inventory record purged permanently for Product ID: " + productId,
                "{\"quantityOnHand\":" + quantity + "}",
                null,
                ActionStatus.SUCCESS,
                request.getRemoteAddr()
        );
    }

    private void calculateAndSetStockStatus(Inventory inventory, Product product) {
        if (inventory.getQuantityOnHand() <= 0) {
            inventory.setStockStatus(StockStatus.OUT_OF_STOCK);
        } else if (inventory.getQuantityReserved() <= 5) {
            inventory.setStockStatus(StockStatus.LOW_STOCK);
        } else {
            inventory.setStockStatus(StockStatus.IN_STOCK);
        }
    }
}