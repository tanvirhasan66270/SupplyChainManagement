package com.example.SCM.service;

import com.example.SCM.dto.request.PurchaseOrderRequestDTO;
import com.example.SCM.dto.response.PurchaseOrderResponseDTO;
import com.example.SCM.enumClass.PurchaseOrderStatus;
import java.util.List;
import java.util.Optional;

public interface PurchaseOrderService {

    PurchaseOrderResponseDTO save(PurchaseOrderRequestDTO dto);

    PurchaseOrderResponseDTO update(Long id, PurchaseOrderRequestDTO dto);

    List<PurchaseOrderResponseDTO> findAll();

    Optional<PurchaseOrderResponseDTO> getById(Long id);

    void delete(Long id);

    PurchaseOrderResponseDTO managerIssuedOrderByToken(String token);

    PurchaseOrderResponseDTO supplierReceivedOrder(String token);
    PurchaseOrderResponseDTO approveOrder(Long id);

    PurchaseOrderResponseDTO updateShipmentQuantityCheck(Long id, int shippedQuantity);

    PurchaseOrderResponseDTO updateStatus(Long id, PurchaseOrderStatus status);
}