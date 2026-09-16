package com.example.SCM.service;

import com.example.SCM.dto.request.OrderLineItemRequestDTO;
import com.example.SCM.dto.response.OrderLineItemResponseDTO;
import java.util.List;
import java.util.Optional;

public interface OrderLineItemService {
    List<OrderLineItemResponseDTO> findByOrderId(Long orderId);
    Optional<OrderLineItemResponseDTO> getById(Long id);
    void deleteItem(Long id);
}