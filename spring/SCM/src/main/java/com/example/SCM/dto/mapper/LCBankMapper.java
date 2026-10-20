package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.LCBankRequestDTO;
import com.example.SCM.dto.response.LCBankResponseDTO;
import com.example.SCM.entity.LCBank;
import org.springframework.stereotype.Component;

@Component
public class LCBankMapper {

    public LCBank toEntity(LCBankRequestDTO dto) {
        if (dto == null) return null;

        LCBank bank = new LCBank();
        bank.setName(dto.getName());
        bank.setSwiftCode(dto.getSwiftCode());
        bank.setBranchName(dto.getBranchName());
        bank.setAddress(dto.getAddress());
        bank.setContactEmail(dto.getContactEmail());
        bank.setContactPhone(dto.getContactPhone());
        return bank;
    }

    public LCBankResponseDTO toResponseDTO(LCBank entity) {
        if (entity == null) return null;

        LCBankResponseDTO dto = new LCBankResponseDTO();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setSwiftCode(entity.getSwiftCode());
        dto.setBranchName(entity.getBranchName());
        dto.setAddress(entity.getAddress());
        dto.setContactEmail(entity.getContactEmail());
        dto.setContactPhone(entity.getContactPhone());
        dto.setCreatedAt(entity.getCreatedAt() != null ? entity.getCreatedAt().toString() : null);
        dto.setUpdatedAt(entity.getUpdatedAt() != null ? entity.getUpdatedAt().toString() : null);
        return dto;
    }
}