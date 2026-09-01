package com.example.SCM.serviceImp;

import com.example.SCM.Util.MailService;
import com.example.SCM.dto.mapper.DeliveryTripMapper;
import com.example.SCM.dto.request.DeliveryTripRequestDTO;
import com.example.SCM.dto.response.DeliveryTripResponseDTO;
import com.example.SCM.entity.*;
import com.example.SCM.enumClass.DeliveryTripStatus;
import com.example.SCM.repository.*;
import com.example.SCM.service.DeliveryTripService;
import com.example.SCM.service.NotificationService;
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
public class DeliveryTripServiceImp implements DeliveryTripService {

    private final DeliveryTripRepository tripRepository;
    private final CustomerRepository customerRepository;
    private final DriverRepository driverRepository;
    private final VehicleRepository vehicleRepository;
    private final DeliveryTripMapper tripMapper;
    private final MailService mailService;
    private final NotificationService notificationService;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Transactional
    @Override
    public DeliveryTripResponseDTO save(DeliveryTripRequestDTO dto) {
        Customer customer = customerRepository.findById(dto.getCustomerId())
                .orElseThrow(() -> new RuntimeException("Customer profile mapping failure"));
        Driver driver = driverRepository.findById(dto.getDriverId())
                .orElseThrow(() -> new RuntimeException("Driver assignment node missing"));
        Vehicle vehicle = vehicleRepository.findById(dto.getVehicleId())
                .orElseThrow(() -> new RuntimeException("Allocated fleet vehicle missing"));

        DeliveryTrip trip = tripMapper.toEntity(dto, customer, driver, vehicle);
        DeliveryTrip savedTrip = tripRepository.save(trip);

        sendTripAssignmentEmail(driver, savedTrip);

        // Send notification to the driver
        try {
            if (driver.getUser() != null && driver.getUser().getId() != null) {
                String recipientId = driver.getUser().getId().toString();
                String title = "New Delivery Trip Assigned";
                String message = String.format(
                        "You have been assigned to a new delivery trip (#%d). Destination: %s.",
                        savedTrip.getId(),
                        savedTrip.getCustomerAddress()
                );
                notificationService.send(recipientId, "TRIP_ALERT", title, message);
            }
        } catch (Exception e) {
            System.err.println("Driver Notification Error: " + e.getMessage());
        }

        // Send notification to the customer
        try {
            if (customer.getUser() != null && customer.getUser().getId() != null) {
                String recipientId = customer.getUser().getId().toString();
                String title = "Delivery Trip Initiated";
                String message = String.format(
                        "A delivery trip (#%d) has been initiated for your shipment to %s.",
                        savedTrip.getId(),
                        savedTrip.getCustomerAddress()
                );
                notificationService.send(recipientId, "TRIP_ALERT", title, message);
            }
        } catch (Exception e) {
            System.err.println("Customer Delivery Trip Notification Error: " + e.getMessage());
        }

        return tripMapper.convertTOResponseDTO(savedTrip);
    }

    @Transactional
    @Override
    public DeliveryTripResponseDTO update(Long id, DeliveryTripRequestDTO dto) {
        DeliveryTrip trip = tripRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Trip blueprint record missing"));

        Customer customer = customerRepository.findById(dto.getCustomerId()).orElse(trip.getCustomer());
        Driver driver = driverRepository.findById(dto.getDriverId()).orElse(trip.getDriver());
        Vehicle vehicle = vehicleRepository.findById(dto.getVehicleId()).orElse(trip.getVehicle());

        tripMapper.updateEntity(dto, trip, customer, driver, vehicle);
        return tripMapper.convertTOResponseDTO(tripRepository.save(trip));
    }

    @Transactional
    @Override
    public DeliveryTripResponseDTO updateTripStatus(Long id, String status, MultipartFile signature, MultipartFile deliveryPhoto) {
        DeliveryTrip trip = tripRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target trip row missing"));

        DeliveryTripStatus newStatus = DeliveryTripStatus.valueOf(status.toUpperCase());
        trip.setStatus(newStatus);

        if (DeliveryTripStatus.DELIVERED == trip.getStatus()) {
            if (signature != null && !signature.isEmpty()) trip.setRecipientSignature(uploadFile(signature, "signatures"));
            if (deliveryPhoto != null && !deliveryPhoto.isEmpty()) trip.setDeliveryPhotoUrl(uploadFile(deliveryPhoto, "deliveries"));
        }

        return tripMapper.convertTOResponseDTO(tripRepository.save(trip));
    }

    @Transactional(readOnly = true)
    @Override
    public List<DeliveryTripResponseDTO> findAll() {
        return tripRepository.findAll().stream()
                .map(tripMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public Optional<DeliveryTripResponseDTO> getById(Long id) {
        return tripRepository.findById(id).map(tripMapper::convertTOResponseDTO);
    }

    @Transactional
    @Override
    public void delete(Long id) {
        if (!tripRepository.existsById(id)) throw new RuntimeException("Trip tracking map index missing");
        tripRepository.deleteById(id);
    }

    private void sendTripAssignmentEmail(Driver driver, DeliveryTrip trip) {
        if (driver == null || driver.getEmail() == null) return;

        String subject = "New SCM Logistics Assignment – Trip Tracker #" + trip.getId();
        String mailText = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: 'Segoe UI', Arial, sans-serif; line-height: 1.6; color: #333333; background-color: #f9f9f9; margin: 0; padding: 0; }
                .container { max-width: 600px; margin: 20px auto; padding: 0; background-color: #ffffff; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
                .header { background-color: #2196F3; color: white; padding: 25px; text-align: center; }
                .header h2 { margin: 0; font-size: 24px; font-weight: 600; }
                .content { padding: 30px; }
                .btn-container { text-align: center; margin: 30px 0; }
                .btn { background-color: #2196F3; color: white !important; padding: 12px 30px; text-decoration: none; font-weight: bold; border-radius: 5px; display: inline-block; }
                .footer { font-size: 0.85em; color: #777777; padding: 20px; background-color: #f1f1f1; text-align: center; border-top: 1px solid #e0e0e0; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h2>New Route Deployment Dispatched</h2>
                </div>
                <div class='content'>
                    <p>Dear Captain <b>%s</b>,</p>
                    <p>A new delivery transit manifest has been assigned to your active profile today by sales team operations.</p>
                    <p><b>Trip Deployment Brief Matrix:</b></p>
                    <ul>
                        <li><b>Client Address Node:</b> %s</li>
                        <li><b>Vehicle Fleet Assigned:</b> %s</li>
                    </ul>
                    <div class='btn-container'>
                        <a href='http://localhost:8085/api/delivery-trips/%d' class='btn'>View Manifest Details</a>
                    </div>
                    <p>Your action is required to trigger routing map console nodes to IN_TRANSIT.</p>
                    <p>Best regards,<br><b>SCM Logistics Support Team</b></p>
                </div>
                <div class='footer'>
                    &copy; %d SCM Enterprise Network Cluster. All rights reserved.
                </div>
            </div>
        </body>
        </html>
        """.formatted(
                driver.getDriverName(),
                trip.getCustomerAddress(),
                trip.getVehicle() != null ? (trip.getVehicle().getPlateNumber()) : "N/A",
                trip.getId(),
                java.time.Year.now().getValue()
        );

        try {
            mailService.senderGeneralMail(driver.getEmail(), subject, mailText);
        } catch (Exception e) {
            System.err.println("Advanced Email Layout failed to deliver: " + e.getMessage());
        }
    }

    private String uploadFile(MultipartFile file, String subFolder) {
        try {
            Path path = Paths.get(uploadDir, subFolder);
            if (!Files.exists(path)) Files.createDirectories(path);
            String fileName = subFolder.toUpperCase() + "_" + UUID.randomUUID() + "_" + file.getOriginalFilename();
            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return subFolder + "/" + fileName;
        } catch (Exception e) {
            throw new RuntimeException("Trip document sync operational exception: " + e.getMessage());
        }
    }
}