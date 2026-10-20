package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.DeliveryTripRequestDTO;
import com.example.SCM.dto.response.DeliveryTripResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.DeliveryTripStatus;
import org.springframework.stereotype.Component;

@Component
public class DeliveryTripMapper {

    public DeliveryTripResponseDTO convertTOResponseDTO(DeliveryTrip entity) {
        if (entity == null) return null;

        DeliveryTripResponseDTO dto = new DeliveryTripResponseDTO();
        dto.setId(entity.getId());
        dto.setDispatcherId(entity.getDispatcherId());
        dto.setStartedAt(entity.getStartedAt());
        dto.setCompletedAt(entity.getCompletedAt());
        dto.setRecipientSignature(entity.getRecipientSignature());
        dto.setDeliveryPhotoUrl(entity.getDeliveryPhotoUrl());
        dto.setCustomerAddress(entity.getCustomerAddress());
        dto.setRemarks(entity.getRemarks());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        if (entity.getStatus() != null) {
            dto.setStatus(entity.getStatus().name());
        }

        if (entity.getCustomer() != null) {
            dto.setCustomerId(entity.getCustomer().getId());
            dto.setRecipientName(entity.getCustomer().getName());
        }

        if (entity.getDriver() != null) {
            dto.setDriverId(entity.getDriver().getId());
            dto.setDriverName(entity.getDriver().getDriverName());
            dto.setDriverPhone(entity.getDriver().getPhone());
            dto.setDriverEmail(entity.getDriver().getEmail());
        }

        if (entity.getVehicle() != null) {
            dto.setVehicleId(entity.getVehicle().getId());
            dto.setVehiclePlateNumber(entity.getVehicle().getPlateNumber());
        }

        return dto;
    }

    public DeliveryTrip toEntity(DeliveryTripRequestDTO dto, Customer customer, Driver driver, Vehicle vehicle) {
        if (dto == null) return null;

        DeliveryTrip entity = new DeliveryTrip();
        entity.setDispatcherId(dto.getDispatcherId());
        entity.setCustomerAddress(dto.getCustomerAddress());
        entity.setRecipientSignature(dto.getRecipientSignature());
        entity.setDeliveryPhotoUrl(dto.getDeliveryPhotoUrl());
        entity.setRemarks(dto.getRemarks());

        entity.setStatus(dto.getStatus() != null ?
                DeliveryTripStatus.valueOf(dto.getStatus().toUpperCase()) : DeliveryTripStatus.PENDING);

        entity.setCustomer(customer);
        entity.setDriver(driver);
        entity.setVehicle(vehicle);

        return entity;
    }

    public void updateEntity(DeliveryTripRequestDTO dto, DeliveryTrip entity, Customer customer, Driver driver, Vehicle vehicle) {
        if (dto == null || entity == null) return;

        if (dto.getDispatcherId() != null) entity.setDispatcherId(dto.getDispatcherId());
        if (dto.getCustomerAddress() != null) entity.setCustomerAddress(dto.getCustomerAddress());
        if (dto.getRecipientSignature() != null) entity.setRecipientSignature(dto.getRecipientSignature());
        if (dto.getDeliveryPhotoUrl() != null) entity.setDeliveryPhotoUrl(dto.getDeliveryPhotoUrl());
        if (dto.getRemarks() != null) entity.setRemarks(dto.getRemarks());

        if (dto.getStatus() != null) {
            entity.setStatus(DeliveryTripStatus.valueOf(dto.getStatus().toUpperCase()));
        }

        if (customer != null) entity.setCustomer(customer);
        if (driver != null) entity.setDriver(driver);
        if (vehicle != null) entity.setVehicle(vehicle);
    }
}