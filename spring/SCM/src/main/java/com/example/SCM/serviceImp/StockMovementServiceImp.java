package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.StockMovementMapper;
import com.example.SCM.dto.request.StockMovementRequestDTO;
import com.example.SCM.dto.response.StockMovementResponseDTO;
import com.example.SCM.entity.Inventory;
import com.example.SCM.entity.Product;
import com.example.SCM.entity.StockMovement;
import com.example.SCM.entity.User;
import com.example.SCM.entity.Warehouse;
import com.example.SCM.repository.InventoryRepository; 
import com.example.SCM.repository.StockMovementRepository;
import com.example.SCM.repository.ProductRepository;
import com.example.SCM.repository.WarehouseRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.service.StockMovementService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StockMovementServiceImp implements StockMovementService {

    private final StockMovementRepository repository;
    private final ProductRepository productRepository;
    private final WarehouseRepository warehouseRepository;
    private final UserRepository userRepository;
    private final InventoryRepository inventoryRepository;
    private final StockMovementMapper mapper;

    @Override
    @Transactional
    public StockMovementResponseDTO logMovement(StockMovementRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Stock movement request data cannot be null");
        }

        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + dto.getProductId()));

        Warehouse warehouse = warehouseRepository.findById(dto.getWarehouseId())
                .orElseThrow(() -> new RuntimeException("Target Warehouse not found with ID: " + dto.getWarehouseId()));

        Warehouse sourceWarehouse = null;
        if (dto.getSourceWarehouseId() != null && dto.getSourceWarehouseId() > 0) {
            sourceWarehouse = warehouseRepository.findById(dto.getSourceWarehouseId())
                    .orElseThrow(() -> new RuntimeException("Source Warehouse not found with ID: " + dto.getSourceWarehouseId()));
        }

        User performer = userRepository.findById(dto.getPerformedBy())
                .orElseThrow(() -> new RuntimeException("User personnel not found with ID: " + dto.getPerformedBy()));

        StockMovement entity = mapper.toEntity(dto, product, warehouse, sourceWarehouse, performer);
        StockMovement savedEntity = repository.saveAndFlush(entity);

        String movementType = savedEntity.getMovementType().name();

        if (movementType.equals("OUTWARD") || movementType.equals("ADJUSTMENT")) {
            Inventory inventory = inventoryRepository.findByProductIdAndWarehouseId(dto.getProductId(), dto.getWarehouseId())
                    .orElseThrow(() -> new RuntimeException("Inventory record not found for this product in the target warehouse!"));

            int updatedQty = inventory.getQuantityOnHand() - dto.getQuantity();
            inventory.setQuantityOnHand(Math.max(updatedQty, 0)); // নেগেটিভ হওয়া রোধ করতে
            inventoryRepository.save(inventory);

        } else if (movementType.equals("TRANSFER")) {
            Inventory sourceInv = inventoryRepository.findByProductIdAndWarehouseId(dto.getProductId(), dto.getSourceWarehouseId())
                    .orElseThrow(() -> new RuntimeException("Source inventory record not found!"));
            sourceInv.setQuantityOnHand(Math.max(sourceInv.getQuantityOnHand() - dto.getQuantity(), 0));
            inventoryRepository.save(sourceInv);

            Inventory targetInv = inventoryRepository.findByProductIdAndWarehouseId(dto.getProductId(), dto.getWarehouseId())
                    .orElseGet(() -> {
                        Inventory newInv = new Inventory();
                        newInv.setProduct(product);
                        newInv.setWarehouse(warehouse);
                        newInv.setQuantityOnHand(0);
                        newInv.setQuantityReserved(0);
                        return newInv;
                    });
            targetInv.setQuantityOnHand(targetInv.getQuantityOnHand() + dto.getQuantity());
            inventoryRepository.save(targetInv);

        } else if (movementType.equals("INWARD")) {
            Inventory inventory = inventoryRepository.findByProductIdAndWarehouseId(dto.getProductId(), dto.getWarehouseId())
                    .orElseGet(() -> {
                        Inventory newInv = new Inventory();
                        newInv.setProduct(product);
                        newInv.setWarehouse(warehouse);
                        newInv.setQuantityOnHand(0);
                        newInv.setQuantityReserved(0);
                        return newInv;
                    });
            inventory.setQuantityOnHand(inventory.getQuantityOnHand() + dto.getQuantity());
            inventoryRepository.save(inventory);
        }

        return mapper.convertTOResponseDTO(savedEntity);
    }

    @Override
    @Transactional(readOnly = true)
    public List<StockMovementResponseDTO> findAll() {
        return repository.findAll().stream()
                .map(mapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<StockMovementResponseDTO> getById(Long id) {
        return repository.findById(id)
                .map(mapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new RuntimeException("Stock Ledger record pointer missing at datastore context. ID: " + id);
        }
        repository.deleteById(id);
    }
}