package com.example.SCM.service;



import com.example.SCM.dto.request.PurchaseRequisitionRequestDTO;
import com.example.SCM.dto.response.PurchaseRequisitionResponseDTO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public interface PurchaseRequisitionService {
    PurchaseRequisitionResponseDTO save(PurchaseRequisitionRequestDTO dto);
    PurchaseRequisitionResponseDTO approveRequisition(Long id);
    PurchaseRequisitionResponseDTO rejectOrCancelRequisition(Long id, String actionType);

    PurchaseRequisitionResponseDTO update(Long id, PurchaseRequisitionRequestDTO dto);
    List<PurchaseRequisitionResponseDTO> findAll();
    Optional<PurchaseRequisitionResponseDTO> getById(Long id);
    void delete(Long id);

}
