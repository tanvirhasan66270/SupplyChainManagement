package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.DistrictMapper;
import com.example.SCM.dto.request.DistrictRequestDTO;
import com.example.SCM.dto.response.DistrictResponseDTO;
import com.example.SCM.entity.Division;
import com.example.SCM.entity.District;
import com.example.SCM.repository.DivisionRepository;
import com.example.SCM.repository.DistrictRepository;
import com.example.SCM.service.DistrictService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DistrictServiceImp implements DistrictService {

    private final DistrictRepository districtRepository;
    private final DivisionRepository divisionRepository;
    private final DistrictMapper districtMapper;

    @Override
    @Transactional
    public DistrictResponseDTO save(DistrictRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("District data cannot be null");

        Division division = divisionRepository.findById(dto.getDivisionId())
                .orElseThrow(() -> new RuntimeException("Division not found with ID: " + dto.getDivisionId()));

        District district = districtMapper.toEntity(dto, division);
        return districtMapper.convertTOResponseDTO(districtRepository.save(district));
    }

    @Override
    @Transactional
    public DistrictResponseDTO update(Long id, DistrictRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Update data cannot be null");

        District district = districtRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("District not found with ID: " + id));

        Division division = district.getDivision();
        if (dto.getDivisionId() != null && !dto.getDivisionId().equals(division.getId())) {
            division = divisionRepository.findById(dto.getDivisionId())
                    .orElseThrow(() -> new RuntimeException("New Division not found with ID: " + dto.getDivisionId()));
        }

        districtMapper.updateEntity(dto, district, division);
        return districtMapper.convertTOResponseDTO(districtRepository.save(district));
    }

    @Override
    @Transactional(readOnly = true)
    public List<DistrictResponseDTO> findAll(boolean onlyActive) {
        List<District> districts = onlyActive ?
                districtRepository.findAllActiveDistricts() :
                districtRepository.findAllDistrictsWithDetails();

        return districts.stream()
                .map(districtMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<DistrictResponseDTO> getByDivisionId(Long divisionId) {
        return districtRepository.findByDivisionId(divisionId).stream()
                .map(districtMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<DistrictResponseDTO> getById(Long id) {
        return districtRepository.findByIdWithDetails(id).map(districtMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!districtRepository.existsById(id)) {
            throw new RuntimeException("District record not found with ID: " + id);
        }
        districtRepository.deleteById(id);
    }
}