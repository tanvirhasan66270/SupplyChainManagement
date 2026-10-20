package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.VehicleMapper;
import com.example.SCM.dto.request.VehicleRequestDTO;
import com.example.SCM.dto.response.VehicleResponseDTO;
import com.example.SCM.entity.Driver;
import com.example.SCM.entity.Vehicle;
import com.example.SCM.repository.DriverRepository;
import com.example.SCM.repository.VehicleRepository;
import com.example.SCM.service.VehicleService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class VehicleServiceImp implements VehicleService {

    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final VehicleMapper vehicleMapper;

    @Override
    @Transactional
    public VehicleResponseDTO save(VehicleRequestDTO dto) {
        if (vehicleRepository.findByPlateNumber(dto.getPlateNumber()).isPresent()) {
            throw new RuntimeException("Vehicle Plate Number '" + dto.getPlateNumber() + "' already exists!");
        }

        Driver driver = null;
        if (dto.getDriverId() != null) {
            driver = driverRepository.findById(dto.getDriverId())
                    .orElseThrow(() -> new RuntimeException("Driver profile not found with ID: " + dto.getDriverId()));
        }

        Vehicle vehicle = vehicleMapper.toEntity(dto, driver);
        return vehicleMapper.convertTOResponseDTO(vehicleRepository.save(vehicle));
    }

    @Override
    @Transactional
    public VehicleResponseDTO update(Long id, VehicleRequestDTO dto) {
        Vehicle vehicle = vehicleRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Vehicle not found with ID: " + id));

        if (vehicleRepository.existsByPlateNumberAndIdNot(dto.getPlateNumber(), id)) {
            throw new RuntimeException("Plate Number '" + dto.getPlateNumber() + "' is already assigned to another vehicle!");
        }

        Driver driver = null;
        if (dto.getDriverId() != null) {
            driver = driverRepository.findById(dto.getDriverId())
                    .orElseThrow(() -> new RuntimeException("Target Driver not found"));
        }

        vehicleMapper.updateEntity(dto, vehicle, driver);
        return vehicleMapper.convertTOResponseDTO(vehicleRepository.save(vehicle));
    }

    @Override
    @Transactional(readOnly = true)
    public List<VehicleResponseDTO> findAll() {
        return vehicleRepository.findAllWithDriverDetails().stream()
                .map(vehicleMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<VehicleResponseDTO> getById(Long id) {
        return vehicleRepository.findByIdWithDriverDetails(id).map(vehicleMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!vehicleRepository.existsById(id)) {
            throw new RuntimeException("Vehicle deployment map not found with ID: " + id);
        }
        vehicleRepository.deleteById(id);
    }
}