package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.QCChecklistMapper;
import com.example.SCM.dto.request.QCChecklistRequestDTO;
import com.example.SCM.dto.response.QCChecklistResponseDTO;
import com.example.SCM.entity.QCChecklist;
import com.example.SCM.entity.QCInspection;
import com.example.SCM.repository.QCChecklistRepository;
import com.example.SCM.repository.QCInspectionRepository;
import com.example.SCM.service.QCChecklistService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class QCChecklistServiceImp implements QCChecklistService {

    private final QCChecklistRepository qcChecklistRepository;
    private final QCInspectionRepository qcInspectionRepository;
    private final QCChecklistMapper qcChecklistMapper;

    @Override
    @Transactional
    public QCChecklistResponseDTO save(QCChecklistRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Checklist data cannot be null");
        }

        QCInspection inspection = qcInspectionRepository.findById(dto.getInspectionId())
                .orElseThrow(() -> new RuntimeException("QC Inspection not found with ID: " + dto.getInspectionId()));

        QCChecklist checklist = qcChecklistMapper.toEntity(dto, inspection);

        QCChecklist savedChecklist = qcChecklistRepository.saveAndFlush(checklist);

        return qcChecklistMapper.convertTOResponseDTO(savedChecklist);
    }

    @Override
    @Transactional
    public QCChecklistResponseDTO update(Long id, QCChecklistRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Update data cannot be null");
        }

        QCChecklist checklist = qcChecklistRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("QC Checklist item not found with ID: " + id));

        QCInspection inspection = checklist.getQcInspection();
        if (dto.getInspectionId() != null && !dto.getInspectionId().equals(inspection.getId())) {
            inspection = qcInspectionRepository.findById(dto.getInspectionId())
                    .orElseThrow(() -> new RuntimeException("New QC Inspection not found with ID: " + dto.getInspectionId()));
        }

        qcChecklistMapper.updateEntity(dto, checklist, inspection);

        QCChecklist updatedChecklist = qcChecklistRepository.saveAndFlush(checklist);

        return qcChecklistMapper.convertTOResponseDTO(updatedChecklist);
    }

    @Override
    @Transactional(readOnly = true)
    public List<QCChecklistResponseDTO> findByInspectionId(Long inspectionId) {
        return qcChecklistRepository.findByInspectionId(inspectionId).stream()
                .map(qcChecklistMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<QCChecklistResponseDTO> getById(Long id) {
        return qcChecklistRepository.findById(id)
                .map(qcChecklistMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!qcChecklistRepository.existsById(id)) {
            throw new RuntimeException("QC Checklist item not found with ID: " + id);
        }
        qcChecklistRepository.deleteById(id);
    }
}