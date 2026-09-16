package com.example.SCM.serviceImp;

import com.example.SCM.Util.TrakingCode.TrackingCodeGenerator;
import com.example.SCM.dto.mapper.POLineItemMapper;
import com.example.SCM.dto.request.POLineItemRequestDTO;
import com.example.SCM.dto.response.POLineItemResponseDTO;
import com.example.SCM.entity.POLineItem;
import com.example.SCM.entity.Product;
import com.example.SCM.entity.PurchaseOrder;
import com.example.SCM.enumClass.POLineItemStatus;
import com.example.SCM.repository.POLineItemRepository;
import com.example.SCM.repository.ProductRepository;
import com.example.SCM.repository.PurchaseOrderRepository;
import com.example.SCM.service.POLineItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class POLineItemServiceImp implements POLineItemService {

    private final POLineItemRepository poLineItemRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final ProductRepository productRepository;
    private final POLineItemMapper poLineItemMapper;
    private final TrackingCodeGenerator trackingCodeGenerator;
    private final com.example.SCM.service.NotificationService notificationService;

    @Override
    @Transactional
    public POLineItemResponseDTO save(POLineItemRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Line item data cannot be null");
        }

        PurchaseOrder order = purchaseOrderRepository.findById(dto.getPoId())
                .orElseThrow(() -> new RuntimeException("Purchase Order not found with ID: " + dto.getPoId()));

        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + dto.getProductId()));

        POLineItem item = poLineItemMapper.toEntity(dto, order, product);

        if (POLineItemStatus.SHIPPED.name().equalsIgnoreCase(dto.getStatus())) {
            item.setTrackingNumber(trackingCodeGenerator.generateTrackingCode());
        }

        POLineItem savedItem = poLineItemRepository.save(item);

        return poLineItemMapper.convertTOResponseDTO(savedItem);
    }

    @Override
    @Transactional
    public POLineItemResponseDTO update(Long id, POLineItemRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Line item data cannot be null");
        }

        POLineItem item = poLineItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PO Line Item not found with ID: " + id));

        Product product = item.getProduct();
        PurchaseOrder order = item.getPurchaseOrder();

        POLineItemStatus oldStatus = item.getStatus();

        poLineItemMapper.updateEntity(dto, item, product);
        POLineItemStatus newStatus = item.getStatus();

        // (PENDING -> SHIPPED)
        if (oldStatus != POLineItemStatus.SHIPPED && newStatus == POLineItemStatus.SHIPPED) {
            if (item.getTrackingNumber() == null) {
                item.setTrackingNumber(trackingCodeGenerator.generateTrackingCode());
            }
        }

        if (oldStatus != POLineItemStatus.CANCELLED && newStatus == POLineItemStatus.CANCELLED) {
            item.setLineTotal(0.0);
        }

        POLineItem updatedItem = poLineItemRepository.save(item);
        
        // Notify Supplier if status changed
        if (oldStatus != newStatus) {
            try {
                if (order != null && order.getSupplier() != null && order.getSupplier().getUser() != null) {
                    notificationService.send(
                        order.getSupplier().getUser().getId().toString(),
                        "PO_LINE_ITEM",
                        "Order Line Status Updated",
                        "Line Item for PO #" + order.getPoNumber() + " is now " + newStatus
                    );
                }
            } catch (Exception ignored) {}
        }

        return poLineItemMapper.convertTOResponseDTO(updatedItem);
    }

    @Override
    @Transactional(readOnly = true)
    public List<POLineItemResponseDTO> findAll() {
        return poLineItemRepository.findAll().stream()
                .map(poLineItemMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<POLineItemResponseDTO> getById(Long id) {
        return poLineItemRepository.findById(id)
                .map(poLineItemMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        POLineItem item = poLineItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("PO Line Item not found with ID: " + id));

        poLineItemRepository.delete(item);
    }

    @Override
    @Transactional(readOnly = true)
    public POLineItemResponseDTO tracking(String trackingNumber) {
        if (trackingNumber == null || trackingNumber.trim().isEmpty()) {
            throw new IllegalArgumentException("Tracking number cannot be null or empty");
        }

        POLineItem item = poLineItemRepository.findByTrackingNumber(trackingNumber)
                .orElseThrow(() -> new RuntimeException("No purchase order item found with Tracking Number: " + trackingNumber));

        return poLineItemMapper.convertTOResponseDTO(item);
    }
}
