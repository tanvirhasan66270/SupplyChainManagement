package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.ShipmentMapper;
import com.example.SCM.dto.request.ShipmentRequestDTO;
import com.example.SCM.dto.response.ShipmentResponseDTO;
import com.example.SCM.entity.PurchaseOrder;
import com.example.SCM.entity.Shipment;
import com.example.SCM.entity.Supplier;
import com.example.SCM.repository.PurchaseOrderRepository;
import com.example.SCM.repository.ShipmentRepository;
import com.example.SCM.repository.SupplierRepository;
import com.example.SCM.entity.User;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.NotificationService;
import com.example.SCM.service.ShipmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.*;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShipmentServiceImp implements ShipmentService {

    private final ShipmentRepository shipmentRepository;
    private final PurchaseOrderRepository poRepository;
    private final SupplierRepository supplierRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final ShipmentMapper shipmentMapper;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Override
    @Transactional
    public ShipmentResponseDTO save(ShipmentRequestDTO dto, MultipartFile file) {
        PurchaseOrder po = poRepository.findById(dto.getPoId())
                .orElseThrow(() -> new RuntimeException("Purchase Order mapping failed for ID: " + dto.getPoId()));

        Supplier supplier = supplierRepository.findById(dto.getSupplierId())
                .orElseThrow(() -> new RuntimeException("Supplier map target not found"));

        if (file != null && !file.isEmpty()) {
            dto.setPodFileUrl(uploadPodFile(file));
        }

        Shipment shipment = shipmentMapper.toEntity(dto, po, supplier);
        shipment.setShipmentNumber("SH-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());

        Shipment savedShipment = shipmentRepository.save(shipment);

        // Send alert notifications to PROCUREMENT, LOGISTICS_OFFICER, and MANAGER
        try {
            String title = "New Cargo Shipment Dispatched: " + savedShipment.getShipmentNumber();
            String message = String.format(
                    "New shipment (%s) dispatched by supplier %s. PO Ref: #%d, Vehicle: %s, Destination: %s.",
                    savedShipment.getShipmentNumber(),
                    supplier.getName() != null ? supplier.getName() : "Supplier",
                    po.getId(),
                    savedShipment.getVehicleNumber(),
                    savedShipment.getSendByAddress()
            );

            // 1. Dispatch to role-level targets
            notificationService.send("PROCUREMENT", "SHIPMENT", title, message);
            notificationService.send("LOGISTICS_OFFICER", "SHIPMENT", title, message);
            notificationService.send("MANAGER", "SHIPMENT", title, message);

            // 2. Dispatch to specific user IDs
            List<Role> targetRoles = List.of(Role.PROCUREMENT, Role.LOGISTICS_OFFICER, Role.MANAGER);
            List<User> targetUsers = userRepository.findUsersByRoles(targetRoles);
            if (targetUsers != null) {
                for (User user : targetUsers) {
                    if (user.getId() != null) {
                        notificationService.send(
                                user.getId().toString(),
                                "SHIPMENT",
                                title,
                                message
                        );
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Shipment Notification Error: " + e.getMessage());
        }

        return shipmentMapper.convertTOResponseDTO(savedShipment);
    }

    @Override
    @Transactional
    public ShipmentResponseDTO update(Long id, ShipmentRequestDTO dto, MultipartFile file) {
        Shipment shipment = shipmentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Shipment track ledger not found with ID: " + id));

        PurchaseOrder po = poRepository.findById(dto.getPoId()).orElse(shipment.getPurchaseOrder());
        Supplier supplier = supplierRepository.findById(dto.getSupplierId()).orElse(shipment.getSupplier());

        if (file != null && !file.isEmpty()) {
            dto.setPodFileUrl(uploadPodFile(file));
        } else {
            dto.setPodFileUrl(shipment.getPodFileUrl());
        }

        shipmentMapper.updateEntity(dto, shipment, po, supplier);
        return shipmentMapper.convertTOResponseDTO(shipmentRepository.save(shipment));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShipmentResponseDTO> findAll() {
        return shipmentRepository.findAllShipmentsWithDetails().stream()
                .map(shipmentMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ShipmentResponseDTO> getById(Long id) {
        return shipmentRepository.findByIdWithDetails(id).map(shipmentMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!shipmentRepository.existsById(id)) throw new RuntimeException("Shipment node not found");
        shipmentRepository.deleteById(id);
    }

    private String uploadPodFile(MultipartFile file) {
        try {
            Path path = Paths.get(uploadDir, "shipments");
            if (!Files.exists(path)) Files.createDirectories(path);

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String fileName = "POD_" + UUID.randomUUID() + ext;
            Files.copy(file.getInputStream(), path.resolve(fileName));
            return fileName;
        } catch (Exception e) {
            throw new RuntimeException("POD file save operational failure: " + e.getMessage());
        }
    }
}