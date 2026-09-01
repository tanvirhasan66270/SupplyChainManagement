package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.DriverMapper;
import com.example.SCM.dto.request.DriverRequestDTO;
import com.example.SCM.dto.response.DriverResponseDTO;
import com.example.SCM.entity.Driver;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.entity.Warehouse;
import com.example.SCM.repository.DriverRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.repository.WarehouseRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.DriverService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DriverServiceImp implements DriverService {

    private final DriverRepository driverRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final WarehouseRepository warehouseRepository;
    private final DriverMapper driverMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Transactional
    @Override
    public DriverResponseDTO save(DriverRequestDTO dto, MultipartFile file) {

        PoliceStation policeStation = dto.getPoliceStationId() != null ?
                policeStationRepository.findById(dto.getPoliceStationId())
                .orElseThrow(() -> new RuntimeException("Target location police station node not found")) : null;

        User user = new User();
        user.setName(dto.getDriverName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(Role.DRIVER);
        user.setActive(false);
        user.setPoliceStation(policeStation);
        User savedUser = userRepository.save(user);

        Set<Warehouse> warehouses = new HashSet<>();
        if (dto.getWarehouseIds() != null && !dto.getWarehouseIds().isEmpty()) {
            warehouses = new HashSet<>(warehouseRepository.findAllById(dto.getWarehouseIds()));
        }

        Driver driver = driverMapper.toDriverEntity(dto, savedUser, warehouses, policeStation);

        if (file != null && !file.isEmpty()) {
            String imagePath = uploadImage(file, dto.getDriverName());
            driver.setImage( imagePath);
        }

        Driver savedDriver = driverRepository.save(driver);
        authService.sendVerificationEmail(savedDriver.getUser().getEmail());

        return driverMapper.convertTOResponseDTO(savedDriver);
    }

    @Transactional
    @Override
    public DriverResponseDTO update(Long id, DriverRequestDTO dto, MultipartFile file) {
        Driver driver = driverRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Driver node signature not resolved at ID: " + id));

        PoliceStation policeStation = driver.getPoliceStation();
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("New target location police station node not found"));
            driver.setPoliceStation(policeStation);
        }

        User user = driver.getUser();
        if (user != null) {
            user.setName(dto.getDriverName());
            user.setEmail(dto.getEmail());
            user.setPhoneNumber(dto.getPhone());
            user.setPoliceStation(policeStation);
            if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
                user.setPassword(passwordEncoder.encode(dto.getPassword()));
            }
            userRepository.save(user);
        }

        driver.setDriverName(dto.getDriverName());
        driver.setPhone(dto.getPhone());
        driver.setAddress(dto.getAddress());
        driver.setNidNumber(dto.getNidNumber());
        driver.setGender(dto.getGender());
        driver.setEmail(dto.getEmail());
        driver.setVehicleType(dto.getVehicleType());
        driver.setVehicleNumber(dto.getVehicleNumber());
        driver.setDob(dto.getDob());
        driver.setRating(dto.getRating());
        driver.setTotalDeliveries(dto.getTotalDeliveries());
        driver.setTotalEarnings(dto.getTotalEarnings());

        if (file != null && !file.isEmpty()) {
            String newImagePath = uploadImage(file, dto.getDriverName());
            driver.setImage(newImagePath);
        }

        if (dto.getWarehouseIds() != null) {
            Set<Warehouse> updatedWarehouses = new HashSet<>(warehouseRepository.findAllById(dto.getWarehouseIds()));
            driver.setWarehouses(updatedWarehouses);
        }

        return driverMapper.convertTOResponseDTO(driverRepository.save(driver));
    }

    @Transactional(readOnly = true)
    @Override
    public List<DriverResponseDTO> findAll() {
        return driverRepository.findAllWithDetails()
                .stream()
                .map(driverMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public Optional<DriverResponseDTO> getById(Long id) {
        return driverRepository.findByIdWithDetails(id).map(driverMapper::convertTOResponseDTO);
    }

    @Transactional
    @Override
    public void delete(Long id) {
        Driver driver = driverRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target Driver domain key not found"));

        driverRepository.delete(driver);
        if (driver.getUser() != null) {
            userRepository.delete(driver.getUser());
        }
    }

    @Override
    public Optional<DriverResponseDTO> findUserById(Long id) {
        return driverRepository.findByUserId(id).map(driverMapper::convertTOResponseDTO);
    }

    private String uploadImage(MultipartFile file, String driverName) {
        try {
            Path path = Paths.get(uploadDir, "driver");
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = "driver";
            if (driverName != null) {
                cleanedName = driverName.trim()
                        .replaceAll("[^a-zA-Z0-9\\s]", "")
                        .replaceAll("\\s+", "_");
            }
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;
        } catch (Exception e) {
            throw new RuntimeException("Driver file upload sequence dropped: " + e.getMessage());
        }
    }
}