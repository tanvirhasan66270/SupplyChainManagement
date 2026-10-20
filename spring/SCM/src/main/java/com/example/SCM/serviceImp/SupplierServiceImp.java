package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.SupplierMapper;
import com.example.SCM.dto.response.SupplierResponseDTO;
import com.example.SCM.dto.request.SupplierRequestDTO;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.Supplier;
import com.example.SCM.entity.User;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.SupplierRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.SupplierService;
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
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class SupplierServiceImp implements SupplierService {

    private final SupplierRepository supplierRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final SupplierMapper supplierMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;



    @Value("${image.upload.dir}")
    private String uploadDir;

    @Override
    @Transactional
    public SupplierResponseDTO save(SupplierRequestDTO dto, MultipartFile file) {

        if (dto.getPassword() == null || dto.getPassword().isEmpty()) {
            throw new RuntimeException("Password cannot be empty!");
        }

        PoliceStation policeStation = null;
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station not found with ID: " + dto.getPoliceStationId()));
        }

        User user = new User();
        user.setName(dto.getName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(Role.SUPPLIER);
        user.setActive(false);
        user.setPoliceStation(policeStation);
        User savedUser = userRepository.save(user);

        if (file != null && !file.isEmpty()) {
            String imagePath = uploadImage(file, dto.getName());
            dto.setImage(imagePath);
        }

        Supplier supplier = supplierMapper.toSupplierEntity(dto, savedUser, policeStation);
        if (file != null && !file.isEmpty()) {
            supplier.setImage(dto.getImage());
        }
        Supplier savedSupplier = supplierRepository.save(supplier);

        authService.sendVerificationEmail(savedSupplier.getUser().getEmail());
        return supplierMapper.toResponseDTO(savedSupplier);
    }

    @Transactional
    @Override
    public SupplierResponseDTO update(Long id, SupplierRequestDTO dto, MultipartFile image) {
        Supplier supplier = supplierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Supplier not found with ID: " + id));

        PoliceStation policeStation = supplier.getPoliceStation();
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station not found"));
            supplier.setPoliceStation(policeStation);
        }

        User user = supplier.getUser();
        if (user != null) {
            user.setName(dto.getName());
            user.setEmail(dto.getEmail());
            user.setPhoneNumber(dto.getPhone());
            user.setPoliceStation(policeStation);
            if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
                user.setPassword(passwordEncoder.encode(dto.getPassword()));
            }
            userRepository.save(user);
        }

        supplier.setName(dto.getName());
        supplier.setContactPerson(dto.getContactPerson());
        supplier.setEmail(dto.getEmail());
        supplier.setPhone(dto.getPhone());
        supplier.setAddress(dto.getAddress());
        supplier.setNidNumber(dto.getNidNumber());
        supplier.setPassportNumber(dto.getPassportNumber());
        supplier.setGender(dto.getGender());

        if (dto.getDob() != null && !dto.getDob().trim().isEmpty()) {
            try {
                supplier.setDob(String.valueOf(java.sql.Date.valueOf(dto.getDob())));
            } catch (IllegalArgumentException e) {
                try {
                    supplier.setDob(String.valueOf(new java.text.SimpleDateFormat("yyyy-MM-dd").parse(dto.getDob())));
                } catch (Exception ex) {
                    // Ignore parsing failure
                }
            }
        }

        supplier.setRating(dto.getRating());
        supplier.setAverageLeadTimeDays(dto.getAverageLeadTimeDays());

        if (image != null && !image.isEmpty()) {
            String newImagePath = uploadImage(image, dto.getName());
            supplier.setImage( newImagePath);
        }

        Supplier updatedSupplier = supplierRepository.save(supplier);
        return supplierMapper.toResponseDTO(updatedSupplier);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SupplierResponseDTO> findAll() {
        return supplierRepository.findAll().stream()
                .map(supplierMapper::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<SupplierResponseDTO> getById(Long id) {
        return supplierRepository.findById(id)
                .map(supplierMapper::toResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Supplier supplier = supplierRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Supplier not found with ID: " + id));

        supplierRepository.delete(supplier);
        if (supplier.getUser() != null) {
            userRepository.delete(supplier.getUser());
        }
    }

    @Override
    public Optional<SupplierResponseDTO> findUserById(Long id) {
        return supplierRepository.findByUserId(id).map(supplierMapper::toResponseDTO);
    }

    private String uploadImage(MultipartFile file, String supplierName) {
        try {
            Path path = Paths.get(uploadDir, "supplier");

            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = "supplier";
            if (supplierName != null) {
                cleanedName = supplierName.trim()
                        .replaceAll("[^a-zA-Z0-9\\s]", "")
                        .replaceAll("\\s+", "_");
            }
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Supplier profile image upload failed: " + e.getMessage());
        }
    }

}