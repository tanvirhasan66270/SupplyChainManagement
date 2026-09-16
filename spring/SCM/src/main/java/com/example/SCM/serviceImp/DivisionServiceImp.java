package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.DivisionMapper;
import com.example.SCM.dto.request.DivisionRequestDTO;
import com.example.SCM.dto.response.DivisionResponseDTO;
import com.example.SCM.entity.Country;
import com.example.SCM.entity.Division;
import com.example.SCM.repository.CountryRepository;
import com.example.SCM.repository.DivisionRepository;
import com.example.SCM.service.DivisionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DivisionServiceImp implements DivisionService {

    private final DivisionRepository divisionRepository;
    private final CountryRepository countryRepository;
    private final DivisionMapper divisionMapper;

    @Override
    @Transactional
    public DivisionResponseDTO save(DivisionRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Division data cannot be null");

        Country country = countryRepository.findById(dto.getCountryId())
                .orElseThrow(() -> new RuntimeException("Country not found with ID: " + dto.getCountryId()));

        Division division = divisionMapper.toEntity(dto, country);
        return divisionMapper.convertTOResponseDTO(divisionRepository.save(division));
    }

    @Override
    @Transactional
    public DivisionResponseDTO update(Long id, DivisionRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Update data cannot be null");

        Division division = divisionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Division not found with ID: " + id));

        Country country = division.getCountry();
        if (dto.getCountryId() != null && !dto.getCountryId().equals(country.getId())) {
            country = countryRepository.findById(dto.getCountryId())
                    .orElseThrow(() -> new RuntimeException("New Country not found with ID: " + dto.getCountryId()));
        }

        divisionMapper.updateEntity(dto, division, country);
        return divisionMapper.convertTOResponseDTO(divisionRepository.save(division));
    }

    @Override
    @Transactional(readOnly = true)
    public List<DivisionResponseDTO> findAll(boolean onlyActive) {
        List<Division> divisions = onlyActive ?
                divisionRepository.findAllActiveDivisions() :
                divisionRepository.findAllDivisionsWithDetails();

        return divisions.stream()
                .map(divisionMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<DivisionResponseDTO> getByCountryId(Long countryId) {
        return divisionRepository.findByCountryId(countryId).stream()
                .map(divisionMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<DivisionResponseDTO> getById(Long id) {
        return divisionRepository.findByIdWithDetails(id).map(divisionMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!divisionRepository.existsById(id)) {
            throw new RuntimeException("Division record not found with ID: " + id);
        }
        divisionRepository.deleteById(id);
    }
}