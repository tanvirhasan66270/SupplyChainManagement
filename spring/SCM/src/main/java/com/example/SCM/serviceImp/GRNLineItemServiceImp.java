package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.GRNLineItemMapper;
import com.example.SCM.dto.request.GRNLineItemRequestDTO;
import com.example.SCM.dto.response.GRNLineItemResponseDTO;
import com.example.SCM.entity.GoodsReceivedNote;
import com.example.SCM.entity.GRNLineItem;
import com.example.SCM.entity.Product;
import com.example.SCM.repository.GoodsReceivedNoteRepository;
import com.example.SCM.repository.GRNLineItemRepository;
import com.example.SCM.repository.ProductRepository;
import com.example.SCM.service.GRNLineItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GRNLineItemServiceImp implements GRNLineItemService {

    private final GRNLineItemRepository grnLineItemRepository;
    private final GoodsReceivedNoteRepository goodsReceivedNoteRepository;
    private final ProductRepository productRepository;
    private final GRNLineItemMapper grnLineItemMapper;


    @Override
    @Transactional
    public GRNLineItemResponseDTO save(GRNLineItemRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Line item data cannot be null");
        }

        GoodsReceivedNote grn = goodsReceivedNoteRepository.findById(dto.getGrnId())
                .orElseThrow(() -> new RuntimeException("Goods Received Note not found with ID: " + dto.getGrnId()));

        Product product = productRepository.findById(dto.getProductId())
                .orElseThrow(() -> new RuntimeException("Product not found with ID: " + dto.getProductId()));

        GRNLineItem lineItem = grnLineItemMapper.toEntity(dto, grn, product);

        GRNLineItem savedItem = grnLineItemRepository.save(lineItem);
        return grnLineItemMapper.convertTOResponseDTO(savedItem);
    }


    @Override
    @Transactional
    public GRNLineItemResponseDTO update(Long id, GRNLineItemRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Update data cannot be null");
        }

        GRNLineItem item = grnLineItemRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("GRN Line Item not found with ID: " + id));

        GoodsReceivedNote grn = item.getGoodsReceivedNote();
        if (dto.getGrnId() != null && !dto.getGrnId().equals(grn.getId())) {
            grn = goodsReceivedNoteRepository.findById(dto.getGrnId())
                    .orElseThrow(() -> new RuntimeException("New Parent GRN not found with ID: " + dto.getGrnId()));
        }

        Product product = item.getProduct();
        if (dto.getProductId() != null && !dto.getProductId().equals(product.getId())) {
            product = productRepository.findById(dto.getProductId())
                    .orElseThrow(() -> new RuntimeException("New Product not found with ID: " + dto.getProductId()));
        }

        grnLineItemMapper.updateEntity(dto, item, grn, product);

        GRNLineItem updatedItem = grnLineItemRepository.save(item);
        return grnLineItemMapper.convertTOResponseDTO(updatedItem);
    }


    @Override
    @Transactional(readOnly = true)
    public List<GRNLineItemResponseDTO> findAll() {
        return grnLineItemRepository.findAll().stream()
                .map(grnLineItemMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }


    @Override
    @Transactional(readOnly = true)
    public Optional<GRNLineItemResponseDTO> getById(Long id) {
        return grnLineItemRepository.findById(id)
                .map(grnLineItemMapper::convertTOResponseDTO);
    }


    @Override
    @Transactional
    public void delete(Long id) {
        if (!grnLineItemRepository.existsById(id)) {
            throw new RuntimeException("GRN Line Item not found with ID: " + id);
        }
        grnLineItemRepository.deleteById(id);
    }
}