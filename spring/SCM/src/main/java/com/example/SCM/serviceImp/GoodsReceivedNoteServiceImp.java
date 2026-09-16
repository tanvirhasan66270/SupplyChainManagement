package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.GRNLineItemMapper;
import com.example.SCM.dto.mapper.GoodsReceivedNoteMapper;
import com.example.SCM.dto.request.GRNLineItemRequestDTO;
import com.example.SCM.dto.request.GoodsReceivedNoteRequestDTO;
import com.example.SCM.dto.response.GoodsReceivedNoteResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.repository.*;
import com.example.SCM.service.GoodsReceivedNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import com.example.SCM.service.NotificationService;
import com.example.SCM.role.Role;

@Service
@RequiredArgsConstructor
public class GoodsReceivedNoteServiceImp implements GoodsReceivedNoteService {

    private final GoodsReceivedNoteRepository goodsReceivedNoteRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final WarehouseRepository warehouseRepository;
    private final GoodsReceivedNoteMapper goodsReceivedNoteMapper;
    private final GRNLineItemMapper gRNLineItemMapper;
    private final NotificationService notificationService;


    @Transactional
    @Override
    public GoodsReceivedNoteResponseDTO save(GoodsReceivedNoteRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("GRN data cannot be null");
        }

        PurchaseOrder po = purchaseOrderRepository.findById(dto.getPoId())
                .orElseThrow(() -> new RuntimeException("Purchase Order not found with ID: " + dto.getPoId()));

        Product product = null;
        if (dto.getProductId() != null) {
            product = productRepository.findById(dto.getProductId())
                    .orElseThrow(() -> new RuntimeException("Product not found with ID: " + dto.getProductId()));
        }

        User receivedBy = userRepository.findById(dto.getReceivedBy())
                .orElseThrow(() -> new RuntimeException("Receiver User not found with ID: " + dto.getReceivedBy()));

        Warehouse warehouse = warehouseRepository.findById(dto.getWarehouseId())
                .orElseThrow(() -> new RuntimeException("Warehouse not found with ID: " + dto.getWarehouseId()));

        User inspectedBy = null;
        if (dto.getInspectedBy() != null) {
            inspectedBy = userRepository.findById(dto.getInspectedBy())
                    .orElseThrow(() -> new RuntimeException("Inspector User not found with ID: " + dto.getInspectedBy()));
        }

        GoodsReceivedNote grn = goodsReceivedNoteMapper.toEntity(dto, po, product, receivedBy, warehouse, inspectedBy);

        if (po.getQuantity() != null) {
            grn.setQuantity(po.getQuantity());
        }

        if (dto.getLineItems() != null && !dto.getLineItems().isEmpty()) {
            for (GRNLineItemRequestDTO itemDto : dto.getLineItems()) {
                Product itemProduct = productRepository.findById(itemDto.getProductId())
                        .orElseThrow(() -> new RuntimeException("Product not found for line item"));

                GRNLineItem lineItem = gRNLineItemMapper.toEntity(itemDto, grn, itemProduct);
                grn.getLineItems().add(lineItem);
            }
        }

        String generatedGrnNumber = "GRN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        grn.setGrnNumber(generatedGrnNumber);

        GoodsReceivedNote savedGrn = goodsReceivedNoteRepository.save(grn);

        try {
            String title = "New Goods Received Note Created: " + savedGrn.getGrnNumber();
            String message = String.format(
                    "New Goods Received Note (%s) created for PO #%s. Received Qty: %d, Warehouse: %s.",
                    savedGrn.getGrnNumber(),
                    po.getPoNumber() != null ? po.getPoNumber() : po.getId().toString(),
                    savedGrn.getReceivedQuantity(),
                    warehouse.getName() != null ? warehouse.getName() : "Warehouse"
            );

            // 1. Dispatch to role-level targets
            notificationService.send("MANAGER", "GRN", title, message);
            if (inspectedBy != null) {
                notificationService.send(inspectedBy.getId().toString(), "GRN", title, message);
            }

            // 2. Dispatch to specific user IDs
            List<Role> targetRoles = List.of(Role.MANAGER);
            List<User> targetUsers = userRepository.findUsersByRoles(targetRoles);
            if (targetUsers != null) {
                for (User user : targetUsers) {
                    if (user.getId() != null) {
                        notificationService.send(
                                user.getId().toString(),
                                "GRN",
                                title,
                                message
                        );
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("GRN Notification Error: " + e.getMessage());
        }

        return goodsReceivedNoteMapper.convertTOResponseDTO(savedGrn);
    }


    @Transactional
    @Override
    public GoodsReceivedNoteResponseDTO update(Long id, GoodsReceivedNoteRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Update data cannot be null");
        }

        GoodsReceivedNote grn = goodsReceivedNoteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Goods Received Note not found with ID: " + id));

        PurchaseOrder po = purchaseOrderRepository.findById(dto.getPoId())
                .orElseThrow(() -> new RuntimeException("Purchase Order not found with ID: " + dto.getPoId()));

        Product product = dto.getProductId() != null ? productRepository.findById(dto.getProductId()).orElse(null) : null;
        Warehouse warehouse = warehouseRepository.findById(dto.getWarehouseId()).orElse(null);
        User inspectedBy = dto.getInspectedBy() != null ? userRepository.findById(dto.getInspectedBy()).orElse(null) : null;

        goodsReceivedNoteMapper.updateEntity(dto, grn, po, product, warehouse, inspectedBy);

        if (po.getQuantity() != null) {
            grn.setQuantity(po.getQuantity());
        }

        GoodsReceivedNote updatedGrn = goodsReceivedNoteRepository.save(grn);
        return goodsReceivedNoteMapper.convertTOResponseDTO(updatedGrn);
    }


    @Transactional(readOnly = true)
    @Override
    public List<GoodsReceivedNoteResponseDTO> findAll() {
        return goodsReceivedNoteRepository.findAll()
                .stream()
                .map(goodsReceivedNoteMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }


    @Transactional(readOnly = true)
    @Override
    public Optional<GoodsReceivedNoteResponseDTO> getById(Long id) {
        return goodsReceivedNoteRepository.findById(id)
                .map(goodsReceivedNoteMapper::convertTOResponseDTO);
    }


    @Transactional
    @Override
    public void delete(Long id) {
        if (!goodsReceivedNoteRepository.existsById(id)) {
            throw new RuntimeException("Goods Received Note not found with ID: " + id);
        }
        goodsReceivedNoteRepository.deleteById(id);
    }

}