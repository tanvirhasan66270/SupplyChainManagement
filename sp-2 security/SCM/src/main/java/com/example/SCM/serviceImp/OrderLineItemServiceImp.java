package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.OrderLineItemMapper;
import com.example.SCM.dto.response.OrderLineItemResponseDTO;
import com.example.SCM.entity.OrderLineItem;
import com.example.SCM.repository.OrderLineItemRepository;
import com.example.SCM.service.OrderLineItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderLineItemServiceImp implements OrderLineItemService {

    private final OrderLineItemRepository lineItemRepository;
    private final OrderLineItemMapper lineItemMapper;

    @Override
    @Transactional(readOnly = true)
    public List<OrderLineItemResponseDTO> findByOrderId(Long orderId) {
        return lineItemRepository.findByCustomerOrderIdWithProduct(orderId).stream()
                .map(lineItemMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<OrderLineItemResponseDTO> getById(Long id) {
        return lineItemRepository.findById(id).map(lineItemMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        OrderLineItem item = lineItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target order line item node missing index"));

        if (item.getCustomerOrder() != null) {
            item.getCustomerOrder().getLineItems().remove(item);
            item.getCustomerOrder().executeCalculations();
        }

        lineItemRepository.delete(item);
    }
}