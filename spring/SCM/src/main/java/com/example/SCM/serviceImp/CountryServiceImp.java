package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.CountryMapper;
import com.example.SCM.dto.request.CountryRequestDTO;
import com.example.SCM.dto.response.CountryResponseDTO;
import com.example.SCM.entity.Country;
import com.example.SCM.repository.CountryRepository;
import com.example.SCM.service.CountryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CountryServiceImp implements CountryService {

    private final CountryRepository countryRepository;
    private final CountryMapper countryMapper;

    @Override
    @Transactional
    public CountryResponseDTO save(CountryRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Country data cannot be null");
        }
        Country country = countryMapper.toEntity(dto);
        Country savedCountry = countryRepository.save(country);
        return countryMapper.convertTOResponseDTO(savedCountry);
    }

    @Override
    @Transactional
    public CountryResponseDTO update(Long id, CountryRequestDTO dto) {
        if (dto == null) {
            throw new IllegalArgumentException("Update data cannot be null");
        }
        Country country = countryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Country not found with ID: " + id));

        countryMapper.updateEntity(dto, country);
        Country updatedCountry = countryRepository.save(country);
        return countryMapper.convertTOResponseDTO(updatedCountry);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CountryResponseDTO> findAll(boolean onlyActive) {
        List<Country> countries = onlyActive ?
                countryRepository.findAllActiveCountriesWithDivisions() :
                countryRepository.findAllCountriesWithDivisions();

        return countries.stream()
                .map(countryMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<CountryResponseDTO> getById(Long id) {
        return countryRepository.findByIdWithDivisions(id)
                .map(countryMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!countryRepository.existsById(id)) {
            throw new RuntimeException("Country record not found with ID: " + id);
        }
        countryRepository.deleteById(id);
    }
}