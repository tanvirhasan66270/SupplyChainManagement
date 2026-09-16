package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.ManagerMapper;
import com.example.SCM.dto.request.ManagerRequestDTO;
import com.example.SCM.dto.response.ManagerResponseDTO;
import com.example.SCM.entity.Manager;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.example.SCM.repository.ManagerRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.ManagerService;
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
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ManagerServiceImp implements ManagerService {

    private final ManagerRepository managerRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final ManagerMapper managerMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;


    @Value("${image.upload.dir}")
    private String uploadDir;

    @Override
    @Transactional
    public ManagerResponseDTO save(ManagerRequestDTO dto, MultipartFile image) {
        if (dto.getPassword() == null || dto.getPassword().isEmpty()) {
            throw new RuntimeException("Credential password cannot be empty for Management creation!");
        }

        PoliceStation policeStation = null;
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station not resolved with ID: " + dto.getPoliceStationId()));
        }

        User user = new User();
        user.setName(dto.getName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(Role.MANAGER);
        user.setActive(false);
        user.setPoliceStation(policeStation);

        User savedUser = userRepository.save(user);

        if (image != null && !image.isEmpty()) {
            String imagePath = uploadImage(image, dto.getName());
            dto.setAddress(imagePath);
        }

        Manager manager = managerMapper.toManagerEntity(dto, savedUser, policeStation);
        if (image != null && !image.isEmpty()) {
            manager.setImage(dto.getAddress());
        }

        Manager savedManager = managerRepository.save(manager);


        authService.sendVerificationEmail(savedManager.getUser().getEmail());

        return managerMapper.convertTOResponseDTO(savedManager);
    }

    @Override
    @Transactional
    public ManagerResponseDTO update(Long id, ManagerRequestDTO dto, MultipartFile file) {
        Manager manager = managerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Manager profile not found at ID: " + id));

        PoliceStation policeStation = manager.getPoliceStation();
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station node mismatch"));
            manager.setPoliceStation(policeStation);
        }

        User user = manager.getUser();
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

        manager.setAddress(dto.getAddress());
        manager.setNidNumber(dto.getNidNumber());
        manager.setPassportNumber(dto.getPassportNumber());
        manager.setDesignation(dto.getDesignation());


        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            manager.setDob(LocalDate.parse(dto.getDob()));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().isBlank()) {
            manager.setJoiningDate(LocalDate.parse(dto.getJoiningDate()));
        }
        if (dto.getGender() != null) {
            manager.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null) {
            manager.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        if (file != null && !file.isEmpty()) {
            String newImagePath = uploadImage(file, dto.getName());
            manager.setImage( newImagePath);
        }

        return managerMapper.convertTOResponseDTO(managerRepository.save(manager));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ManagerResponseDTO> findAll() {
        return managerRepository.findAllWithDetails().stream()
                .map(managerMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ManagerResponseDTO> getById(Long id) {
        return managerRepository.findById(id).map(managerMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Manager manager = managerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target Manager key mapping missing"));
        managerRepository.delete(manager);
        if (manager.getUser() != null) {
            userRepository.delete(manager.getUser());
        }
    }

    @Override
    public Optional<ManagerResponseDTO> findUserById(Long id) {
        return managerRepository.findByUserId(id)
                .map(managerMapper::convertTOResponseDTO);

    }

    private String uploadImage(MultipartFile file, String name) {
        try {
            Path path = Paths.get(uploadDir, "manager");
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = "manager";
            if (name != null) {
                cleanedName = name.trim()
                        .replaceAll("[^a-zA-Z0-9\\s]", "")
                        .replaceAll("\\s+", "_");
            }
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;
        } catch (Exception e) {
            throw new RuntimeException("Manager system file upload fault: " + e.getMessage());
        }
    }



}