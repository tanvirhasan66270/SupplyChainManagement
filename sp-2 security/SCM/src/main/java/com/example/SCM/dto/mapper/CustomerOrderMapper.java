package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.CustomerOrderRequestDTO;
import com.example.SCM.dto.response.CustomerOrderResponseDTO;
import com.example.SCM.dto.response.OrderLineItemResponseDTO;
import com.example.SCM.entity.CustomerOrder;
import com.example.SCM.entity.OrderLineItem;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.CustomerOrderStatus;
import com.example.SCM.enumClass.PaymentMethod;
import com.example.SCM.enumClass.ServiceType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class CustomerOrderMapper {

    private final OrderLineItemMapper lineItemMapper;

    public CustomerOrder toEntity(CustomerOrderRequestDTO dto, User customer) {
        CustomerOrder order = new CustomerOrder();
        order.setCustomer(customer);
        order.setCustomerName(customer != null ? customer.getName() : null);
        order.setCustomerEmail(customer != null ? customer.getEmail() : null);
        order.setDeliveryAddress(dto.getDeliveryAddress());
        order.setDeliveryPhone(dto.getDeliveryPhone());
        order.setRemarks(dto.getRemarks());
        order.setCodAmount(dto.getCodAmount());
        order.setCurrency(dto.getCurrency() != null ? dto.getCurrency().toUpperCase() : "BDT");
        order.setServiceType(dto.getServiceType() != null && !dto.getServiceType().isBlank() ?
                ServiceType.valueOf(dto.getServiceType().toUpperCase()) : ServiceType.STANDARD);
        order.setPaymentMethod(dto.getPaymentMethod() != null && !dto.getPaymentMethod().isBlank() ?
                PaymentMethod.valueOf(dto.getPaymentMethod().toUpperCase()) : null);
        order.setCustomerAccountNumber(dto.getCustomerAccountNumber());
        order.setPaymentCheckImage(dto.getPaymentCheckImage());
        order.setStatus(dto.getStatus() != null && !dto.getStatus().isBlank() ?
                CustomerOrderStatus.valueOf(dto.getStatus().toUpperCase()) : CustomerOrderStatus.PENDING);
        order.setEstimatedDelivery(dto.getEstimatedDelivery() != null && !dto.getEstimatedDelivery().isBlank() ?
                LocalDate.parse(dto.getEstimatedDelivery()) : null);
        order.setLineItems(new ArrayList<>());



        if (dto.getItems() != null) {
            dto.getItems().forEach(itemDto -> {
                OrderLineItem item = lineItemMapper.toEntity(itemDto);
                if (item != null) {
                    order.addLineItem(item);
                }
            });
        }

        return order;
    }

    public CustomerOrderResponseDTO convertTOResponseDTO(CustomerOrder entity) {
        CustomerOrderResponseDTO dto = new CustomerOrderResponseDTO();
        dto.setId(entity.getId());
        dto.setOrderNumber(entity.getOrderNumber());
        dto.setCustomerId(entity.getCustomerId());
        dto.setCustomerName(entity.getCustomerName() != null ? entity.getCustomerName() :
                (entity.getCustomer() != null ? entity.getCustomer().getName() : "Walk-in Customer"));
        dto.setCustomerEmail(entity.getCustomerEmail() != null ? entity.getCustomerEmail() :
                (entity.getCustomer() != null ? entity.getCustomer().getEmail() : "no-email@scmlogistics.com"));

        dto.setItemSubtotal(entity.getItemSubtotal());
        dto.setWeight(entity.getWeight());
        dto.setServiceType(entity.getServiceType() != null ? entity.getServiceType().name() : null);
        dto.setCodAmount(entity.getCodAmount());
        dto.setDeliveryCharge(entity.getDeliveryCharge());
        dto.setTotalAmount(entity.getTotalAmount());
        dto.setPaidAmount(entity.getPaidAmount());
        dto.setDueAmount(entity.getDueAmount());
        dto.setPaymentStatus(entity.getPaymentStatus() != null ? entity.getPaymentStatus().name() : null);
        dto.setPaymentMethod(entity.getPaymentMethod() != null ? entity.getPaymentMethod().name() : null);
        dto.setCustomerAccountNumber(entity.getCustomerAccountNumber());
        dto.setPaymentCheckImage(entity.getPaymentCheckImage());
        dto.setCurrency(entity.getCurrency());
        dto.setStatus(entity.getStatus() != null ? entity.getStatus().name() : null);
        dto.setDeliveryAddress(entity.getDeliveryAddress());
        dto.setDeliveryPhone(entity.getDeliveryPhone());
        dto.setRemarks(entity.getRemarks());
        dto.setRemarks(entity.getRemarks());
        dto.setEstimatedDelivery(entity.getEstimatedDelivery() != null ? entity.getEstimatedDelivery().toString() : null);
        dto.setCreatedAt(entity.getCreatedAt() != null ? entity.getCreatedAt().toString() : null);

        if (entity.getLineItems() != null) {
            List<OrderLineItemResponseDTO> itemDTOs = entity.getLineItems().stream()
                    .map(lineItemMapper::convertTOResponseDTO)
                    .collect(Collectors.toList());
            dto.setLineItems(itemDTOs);
        }

        return dto;
    }
}