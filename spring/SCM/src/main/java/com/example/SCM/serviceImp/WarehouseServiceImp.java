package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.WarehouseMapper;
import com.example.SCM.dto.request.WarehouseRequestDTO;
import com.example.SCM.dto.response.WarehouseResponseDTO;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.Warehouse;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.WarehouseRepository;
import com.example.SCM.service.WarehouseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WarehouseServiceImp implements WarehouseService {

    private final WarehouseRepository warehouseRepository;
    private final PoliceStationRepository policeStationRepository;
    private final WarehouseMapper warehouseMapper;

    @Override
    @Transactional
    public WarehouseResponseDTO save(WarehouseRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Request data cannot be null");

        // Unique Constraint Validations (Name & Email)
        if (warehouseRepository.findByName(dto.getName()).isPresent()) {
            throw new RuntimeException("Warehouse name '" + dto.getName() + "' already exists!");
        }
        if (warehouseRepository.findByEmail(dto.getEmail()).isPresent()) {
            throw new RuntimeException("Warehouse email '" + dto.getEmail() + "' already exists!");
        }

        PoliceStation policeStation = null;
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station not found with ID: " + dto.getPoliceStationId()));
        }

        Warehouse warehouse = warehouseMapper.toEntity(dto, policeStation);
        return warehouseMapper.toResponseDTO(warehouseRepository.save(warehouse));
    }

    @Override
    @Transactional
    public WarehouseResponseDTO update(Long id, WarehouseRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Request data cannot be null");

        Warehouse warehouse = warehouseRepository.findByIdWithLocationDetails(id)
                .orElseThrow(() -> new RuntimeException("Warehouse not found with ID: " + id));

        // Name Conflict Verification
        if (dto.getName() != null && !dto.getName().equals(warehouse.getName())) {
            if (warehouseRepository.findByName(dto.getName()).isPresent()) {
                throw new RuntimeException("Warehouse name '" + dto.getName() + "' is already taken!");
            }
        }

        // Email Conflict Verification
        if (dto.getEmail() != null && !dto.getEmail().equals(warehouse.getEmail())) {
            if (warehouseRepository.findByEmail(dto.getEmail()).isPresent()) {
                throw new RuntimeException("Warehouse email '" + dto.getEmail() + "' is already taken!");
            }
        }

        PoliceStation policeStation = warehouse.getPoliceStation();
        if (dto.getPoliceStationId() != null && (policeStation == null || !dto.getPoliceStationId().equals(policeStation.getId()))) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("New Police Station not found with ID: " + dto.getPoliceStationId()));
        }

        warehouseMapper.updateEntity(dto, warehouse, policeStation);
        return warehouseMapper.toResponseDTO(warehouseRepository.save(warehouse));
    }

    @Override
    @Transactional(readOnly = true)
    public List<WarehouseResponseDTO> findAll() {
        return warehouseRepository.findAllWithLocationDetails().stream()
                .map(warehouseMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<WarehouseResponseDTO> getById(Long id) {
        return warehouseRepository.findByIdWithLocationDetails(id)
                .map(warehouseMapper::toResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!warehouseRepository.existsById(id)) {
            throw new RuntimeException("Warehouse not found with ID: " + id);
        }
        warehouseRepository.deleteById(id);
    }
}