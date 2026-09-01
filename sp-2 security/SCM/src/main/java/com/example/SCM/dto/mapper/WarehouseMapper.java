package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.WarehouseRequestDTO;
import com.example.SCM.dto.response.WarehouseResponseDTO;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.Warehouse;
import org.springframework.stereotype.Component;

@Component
public class    WarehouseMapper {

    public Warehouse toEntity(WarehouseRequestDTO dto, PoliceStation policeStation) {

        Warehouse warehouse = new Warehouse();
        warehouse.setName(dto.getName());
        warehouse.setEmail(dto.getEmail()); // 🔗 Mapping Email
        warehouse.setLocation(dto.getLocation());
        warehouse.setCapacity(dto.getCapacity());
        warehouse.setManagerId(dto.getManagerId());
        warehouse.setActive(dto.isActive());
        warehouse.setPoliceStation(policeStation);

        return warehouse;
    }

    public WarehouseResponseDTO toResponseDTO(Warehouse warehouse) {

        WarehouseResponseDTO dto = new WarehouseResponseDTO();
        dto.setId(warehouse.getId());
        dto.setName(warehouse.getName());
        dto.setEmail(warehouse.getEmail());
        dto.setLocation(warehouse.getLocation());
        dto.setCapacity(warehouse.getCapacity());
        dto.setManagerId(warehouse.getManagerId());
        dto.setActive(warehouse.isActive());
        dto.setCreatedAt(warehouse.getCreatedAt());
        dto.setUpdatedAt(warehouse.getUpdatedAt());

        StringBuilder fullAddress = new StringBuilder();

        if (warehouse.getLocation() != null && !warehouse.getLocation().isBlank()) {
            fullAddress.append(warehouse.getLocation());
        }

        if (warehouse.getPoliceStation() != null) {
            PoliceStation ps = warehouse.getPoliceStation();
            dto.setPoliceStationId(ps.getId());
            dto.setPoliceStationName(ps.getName());

            if (fullAddress.length() > 0) fullAddress.append(", ");
            fullAddress.append("PS: ").append(ps.getName());

            if (ps.getDistrict() != null) {
                dto.setDistrictName(ps.getDistrict().getName());
                fullAddress.append(", District: ").append(ps.getDistrict().getName());

                if (ps.getDistrict().getDivision() != null) {
                    dto.setDivisionName(ps.getDistrict().getDivision().getName());

                    fullAddress.append(", Division: ").append(ps.getDistrict().getDivision().getName());
                }
            }
        }

        dto.setAddress(fullAddress.toString());
        return dto;
    }

    public void updateEntity(WarehouseRequestDTO dto, Warehouse warehouse, PoliceStation policeStation) {

        if (dto.getName() != null) warehouse.setName(dto.getName());
        if (dto.getEmail() != null) warehouse.setEmail(dto.getEmail()); // 🔗 Updating Email
        if (dto.getLocation() != null) warehouse.setLocation(dto.getLocation());

        warehouse.setCapacity(dto.getCapacity());
        warehouse.setManagerId(dto.getManagerId());
        warehouse.setActive(dto.isActive());

        if (policeStation != null) {
            warehouse.setPoliceStation(policeStation);
        }
    }
}