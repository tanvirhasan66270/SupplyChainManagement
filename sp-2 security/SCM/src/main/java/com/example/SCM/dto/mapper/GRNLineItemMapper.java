package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.GRNLineItemRequestDTO;
import com.example.SCM.dto.response.GRNLineItemResponseDTO;
import com.example.SCM.entity.GoodsReceivedNote;
import com.example.SCM.entity.GRNLineItem;
import com.example.SCM.entity.Product;
import org.springframework.stereotype.Component;

@Component
public class GRNLineItemMapper {


    public GRNLineItemResponseDTO convertTOResponseDTO(GRNLineItem item) {

        GRNLineItemResponseDTO dto = new GRNLineItemResponseDTO();
        dto.setId(item.getId());
        dto.setQuantityOrdered(item.getQuantityOrdered());
        dto.setQuantityReceived(item.getQuantityReceived());

        // Parent GRN Details Flattening
        if (item.getGoodsReceivedNote() != null) {
            dto.setGrnId(item.getGoodsReceivedNote().getId());
            dto.setGrnNumber(item.getGoodsReceivedNote().getGrnNumber());
        }

        // Product Details Flattening
        if (item.getProduct() != null) {
            dto.setProductId(item.getProduct().getId());
            dto.setProductName(item.getProduct().getName());
        }

        return dto;
    }


    public GRNLineItem toEntity(GRNLineItemRequestDTO dto, GoodsReceivedNote grn, Product product) {


        GRNLineItem item = new GRNLineItem();
        item.setQuantityOrdered(dto.getQuantityOrdered());
        item.setQuantityReceived(dto.getQuantityReceived());

        // সার্ভিস লেয়ার থেকে লোড হওয়া অবজেক্ট রিলেশন রিলিংকিং
        item.setGoodsReceivedNote(grn);
        item.setProduct(product);

        return item;
    }


    public void updateEntity(GRNLineItemRequestDTO dto, GRNLineItem item, GoodsReceivedNote grn, Product product) {
        if (dto == null || item == null) {
            return;
        }

        item.setQuantityOrdered(dto.getQuantityOrdered());
        item.setQuantityReceived(dto.getQuantityReceived());

        if (grn != null) item.setGoodsReceivedNote(grn);
        if (product != null) item.setProduct(product);
    }
}