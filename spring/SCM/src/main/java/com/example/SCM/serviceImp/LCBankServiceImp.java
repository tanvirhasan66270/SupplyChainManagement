package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.LCBankMapper;
import com.example.SCM.dto.request.LCBankRequestDTO;
import com.example.SCM.dto.response.LCBankResponseDTO;
import com.example.SCM.entity.LCBank;
import com.example.SCM.repository.LCBankRepository;
import com.example.SCM.service.LCBankService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class LCBankServiceImp implements LCBankService {

    private final LCBankRepository bankRepository;
    private final LCBankMapper bankMapper;

    @Transactional
    @Override
    public LCBankResponseDTO save(LCBankRequestDTO dto) {
        if (dto.getSwiftCode() != null && bankRepository.findBySwiftCode(dto.getSwiftCode()).isPresent()) {
            throw new RuntimeException("Bank with this SWIFT code already registered cluster context.");
        }
        LCBank bank = bankMapper.toEntity(dto);
        LCBank savedBank = bankRepository.save(bank);
        return bankMapper.toResponseDTO(savedBank);
    }

    @Transactional
    @Override
    public LCBankResponseDTO update(Long id, LCBankRequestDTO dto) {
        LCBank bank = bankRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target LC Bank matrix record row missing for ID: " + id));

        if (dto.getName() != null) bank.setName(dto.getName());
        if (dto.getSwiftCode() != null) bank.setSwiftCode(dto.getSwiftCode());
        if (dto.getBranchName() != null) bank.setBranchName(dto.getBranchName());
        if (dto.getAddress() != null) bank.setAddress(dto.getAddress());
        if (dto.getContactEmail() != null) bank.setContactEmail(dto.getContactEmail());
        if (dto.getContactPhone() != null) bank.setContactPhone(dto.getContactPhone());

        LCBank updatedBank = bankRepository.save(bank);
        return bankMapper.toResponseDTO(updatedBank);
    }

    @Transactional(readOnly = true)
    @Override
    public List<LCBankResponseDTO> findAll() {
        return bankRepository.findAll().stream()
                .map(bankMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public Optional<LCBankResponseDTO> getById(Long id) {
        return bankRepository.findById(id).map(bankMapper::toResponseDTO);
    }

    @Transactional
    @Override
    public void delete(Long id) {
        LCBank bank = bankRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target LC Bank row missing mapping index"));
        bankRepository.delete(bank);
    }
}