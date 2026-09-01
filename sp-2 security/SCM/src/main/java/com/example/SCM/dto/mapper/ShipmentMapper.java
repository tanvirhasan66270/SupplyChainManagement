package com.example.SCM.dto.mapper;

import com.example.SCM.dto.request.ShipmentRequestDTO;
import com.example.SCM.dto.response.ShipmentResponseDTO;
import com.example.SCM.entity.PurchaseOrder;
import com.example.SCM.entity.Shipment;
import com.example.SCM.entity.Supplier;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
public class ShipmentMapper {

    public ShipmentResponseDTO convertTOResponseDTO(Shipment entity) {

        ShipmentResponseDTO dto = new ShipmentResponseDTO();
        dto.setId(entity.getId());
        dto.setShipmentNumber(entity.getShipmentNumber());
        dto.setVehicleNumber(entity.getVehicleNumber());
        dto.setCaptainRegistrationNumber(entity.getCaptainRegistrationNumber());
        dto.setAssignedByEmail(entity.getAssignedByEmail());
        dto.setOrigin(entity.getOrigin());
        dto.setSendByAddress(entity.getSendByAddress());
        dto.setEstimatedDelivery(entity.getEstimatedDelivery().toString());
        dto.setTransportCost(entity.getTransportCost());
        dto.setShipmentQuantity(entity.getShipmentQuantity());
        dto.setPodFileUrl(entity.getPodFileUrl());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());

        // PurchaseOrder Fields mapping
        if (entity.getPurchaseOrder() != null) {
            PurchaseOrder po = entity.getPurchaseOrder();
            dto.setPoId(po.getId());
            dto.setPoQuantity(po.getQuantity());
            dto.setPoTotalAmount(po.getTotalAmount());
        }

        // Supplier Fields mapping
        if (entity.getSupplier() != null) {
            Supplier s = entity.getSupplier();
            dto.setSupplierId(s.getId());
            dto.setSupplierName(s.getName());
            dto.setSupplierContactPerson(s.getContactPerson());
            dto.setSupplierEmail(s.getEmail());
            dto.setSupplierPhone(s.getPhone());
            dto.setSupplierAddress(s.getAddress());
        }
        return dto;
    }

    public Shipment toEntity(ShipmentRequestDTO dto, PurchaseOrder po, Supplier supplier) {

        Shipment entity = new Shipment();
        entity.setVehicleNumber(dto.getVehicleNumber());
        entity.setCaptainRegistrationNumber(dto.getCaptainRegistrationNumber());
        entity.setAssignedByEmail(dto.getAssignedByEmail());
        entity.setOrigin(dto.getOrigin());
        entity.setSendByAddress(dto.getSendByAddress());
        entity.setEstimatedDelivery(LocalDate.parse(dto.getEstimatedDelivery()));
        entity.setTransportCost(dto.getTransportCost());
        entity.setShipmentQuantity(dto.getShipmentQuantity());
        entity.setPodFileUrl(dto.getPodFileUrl());
        entity.setPurchaseOrder(po);
        entity.setSupplier(supplier);

        return entity;
    }

    public void updateEntity(ShipmentRequestDTO dto, Shipment entity, PurchaseOrder po, Supplier supplier) {
        if (dto == null || entity == null) return;

        if (dto.getVehicleNumber() != null) entity.setVehicleNumber(dto.getVehicleNumber());
        if (dto.getCaptainRegistrationNumber() != null) entity.setCaptainRegistrationNumber(dto.getCaptainRegistrationNumber());
        if (dto.getAssignedByEmail() != null) entity.setAssignedByEmail(dto.getAssignedByEmail());
        if (dto.getOrigin() != null) entity.setOrigin(dto.getOrigin());
        if (dto.getSendByAddress() != null) entity.setSendByAddress(dto.getSendByAddress());
        if (dto.getEstimatedDelivery() != null) entity.setEstimatedDelivery(LocalDate.parse(dto.getEstimatedDelivery()));
        if (dto.getTransportCost() != null) entity.setTransportCost(dto.getTransportCost());
        if (dto.getShipmentQuantity() != null) entity.setShipmentQuantity(dto.getShipmentQuantity());

        if (po != null) entity.setPurchaseOrder(po);
        if (supplier != null) entity.setSupplier(supplier);
    }
}