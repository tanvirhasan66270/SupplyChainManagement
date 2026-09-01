package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.OrderLineItemRequestDTO;
import com.example.SCM.dto.response.OrderLineItemResponseDTO;
import com.example.SCM.entity.OrderLineItem;
import com.example.SCM.entity.Product;
import com.example.SCM.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrderLineItemMapper {

    private final ProductRepository productRepository;


    public OrderLineItem toEntity(OrderLineItemRequestDTO dto) {

        OrderLineItem item = new OrderLineItem();
        item.setQuantity(dto.getQuantity());
        item.setRemarks(dto.getRemarks());


        if (dto.getProductId() != null) {
            Product product = productRepository.findById(dto.getProductId())
                    .orElseThrow(() -> new RuntimeException("Product instance not found for ID: " + dto.getProductId()));
            item.setProduct(product);
            item.setUnitPrice(product.getSellingPrice()); 

//            if (dto.getUnitPrice() > 0) {
//                item.setUnitPrice(dto.getUnitPrice());
//            } else {
//                item.setUnitPrice(product.getSellingPrice());
//            }

            item.setLineTotal(item.getQuantity() * item.getUnitPrice());
            item.setItemWeightTotal(product.getWeight() * item.getQuantity());
        }

        return item;
    }


    public OrderLineItemResponseDTO convertTOResponseDTO(OrderLineItem entity) {

        OrderLineItemResponseDTO dto = new OrderLineItemResponseDTO();
        dto.setId(entity.getId());
        dto.setQuantity(entity.getQuantity());
        dto.setUnitPrice(entity.getUnitPrice());
        dto.setLineTotal(entity.getLineTotal());
        dto.setItemWeightTotal(entity.getItemWeightTotal());
        dto.setRemarks(entity.getRemarks());

        if (entity.getProduct() != null) {
            dto.setProductId(entity.getProduct().getId());
            dto.setProductName(entity.getProduct().getName());
            dto.setProductCode(entity.getProduct().getProductCode());
        }

        return dto;
    }
}