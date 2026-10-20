package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.VehicleRequestDTO;
import com.example.SCM.dto.response.VehicleResponseDTO;
import com.example.SCM.entity.Driver;
import com.example.SCM.entity.Vehicle;
import com.example.SCM.enumClass.VehicleStatus;
import com.example.SCM.enumClass.VehicleType;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class VehicleMapper {

    public VehicleResponseDTO convertTOResponseDTO(Vehicle entity) {

        VehicleResponseDTO dto = new VehicleResponseDTO();
        dto.setId(entity.getId());
        dto.setPlateNumber(entity.getPlateNumber());
        dto.setType(entity.getType().name());
        dto.setCapacity(entity.getCapacity());
        dto.setStatus(entity.getStatus().name());
        if (entity.getLastServiceDate() != null) {
            dto.setLastServiceDate(entity.getLastServiceDate().toString());
        }
        dto.setFuelLevel(entity.getFuelLevel());

        if (entity.getDriver() != null) {
            dto.setDriverId(entity.getDriver().getId());
            dto.setDriverName(entity.getDriver().getDriverName());
            dto.setDriverPhone(entity.getDriver().getPhone());
            dto.setDriverEmail(entity.getDriver().getEmail());
        }
        return dto;
    }

    public Vehicle toEntity(VehicleRequestDTO dto, Driver driver) {

        Vehicle entity = new Vehicle();
        entity.setPlateNumber(dto.getPlateNumber());
        entity.setType(VehicleType.valueOf(dto.getType().toUpperCase()));
        entity.setCapacity(dto.getCapacity());
        entity.setStatus(VehicleStatus.valueOf(dto.getStatus().toUpperCase()));
        if (dto.getLastServiceDate() != null && !dto.getLastServiceDate().isEmpty()) {
            entity.setLastServiceDate(LocalDate.parse(dto.getLastServiceDate()));
        }
        entity.setFuelLevel(dto.getFuelLevel());
        entity.setDriver(driver);

        return entity;
    }

    public void updateEntity(VehicleRequestDTO dto, Vehicle entity, Driver driver) {
        if (dto == null || entity == null) return;

        if (dto.getPlateNumber() != null) entity.setPlateNumber(dto.getPlateNumber());
        if (dto.getType() != null) entity.setType(VehicleType.valueOf(dto.getType().toUpperCase()));
        if (dto.getCapacity() != null) entity.setCapacity(dto.getCapacity());
        if (dto.getStatus() != null) entity.setStatus(VehicleStatus.valueOf(dto.getStatus().toUpperCase()));
        if (dto.getLastServiceDate() != null && !dto.getLastServiceDate().isEmpty()) {
            entity.setLastServiceDate(LocalDate.parse(dto.getLastServiceDate()));
        }
        if (dto.getFuelLevel() != null) entity.setFuelLevel(dto.getFuelLevel());

        entity.setDriver(driver);
    }
}