package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.PoliceStationMapper;
import com.example.SCM.dto.request.PoliceStationRequestDTO;
import com.example.SCM.dto.response.PoliceStationResponseDTO;
import com.example.SCM.entity.District;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.repository.DistrictRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.service.PoliceStationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PoliceStationServiceImp implements PoliceStationService {

    private final PoliceStationRepository policeStationRepository;
    private final DistrictRepository districtRepository;
    private final PoliceStationMapper policeStationMapper;

    @Override
    @Transactional
    public PoliceStationResponseDTO save(PoliceStationRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Station data cannot be null");

        District district = districtRepository.findById(dto.getDistrictId())
                .orElseThrow(() -> new RuntimeException("District not found with ID: " + dto.getDistrictId()));

        PoliceStation station = policeStationMapper.toEntity(dto, district);
        return policeStationMapper.convertTOResponseDTO(policeStationRepository.save(station));
    }

    @Override
    @Transactional
    public PoliceStationResponseDTO update(Long id, PoliceStationRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Update data cannot be null");

        PoliceStation station = policeStationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Police Station not found with ID: " + id));

        District district = station.getDistrict();
        if (dto.getDistrictId() != null && !dto.getDistrictId().equals(district.getId())) {
            district = districtRepository.findById(dto.getDistrictId())
                    .orElseThrow(() -> new RuntimeException("New District not found with ID: " + dto.getDistrictId()));
        }

        policeStationMapper.updateEntity(dto, station, district);
        return policeStationMapper.convertTOResponseDTO(policeStationRepository.save(station));
    }

    @Override
    @Transactional(readOnly = true)
    public List<PoliceStationResponseDTO> findAll(boolean onlyActive) {
        List<PoliceStation> stations = onlyActive ?
                policeStationRepository.findAllActiveStations() :
                policeStationRepository.findAllStationsWithDetails();

        return stations.stream()
                .map(policeStationMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<PoliceStationResponseDTO> getByDistrictId(Long districtId) {
        return policeStationRepository.findByDistrictId(districtId).stream()
                .map(policeStationMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<PoliceStationResponseDTO> getById(Long id) {
        return policeStationRepository.findByIdWithDetails(id).map(policeStationMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!policeStationRepository.existsById(id)) {
            throw new RuntimeException("Police Station not found with ID: " + id);
        }
        policeStationRepository.deleteById(id);
    }

    @Override
    @Transactional
    public List<PoliceStationResponseDTO> search(String keyword) {
        return policeStationRepository.searchStations(keyword.trim())
                .stream()
                .map(policeStationMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

}