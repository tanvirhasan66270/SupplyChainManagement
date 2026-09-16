package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.LogisticsOfficerMapper;
import com.example.SCM.dto.request.LogisticsOfficerRequestDTO;
import com.example.SCM.dto.response.LogisticsOfficerResponseDTO;
import com.example.SCM.entity.Logistics_Officer;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.example.SCM.repository.LogisticsOfficerRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.LogisticsOfficerService;
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
public class LogisticsOfficerServiceImp implements LogisticsOfficerService {

    private final LogisticsOfficerRepository officerRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final LogisticsOfficerMapper officerMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;


    @Value("${image.upload.dir}")
    private String uploadDir;

    @Override
    @Transactional
    public LogisticsOfficerResponseDTO save(LogisticsOfficerRequestDTO dto, MultipartFile file) {

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
        user.setRole(Role.LOGISTICS_OFFICER);
        user.setPoliceStation(policeStation);
        user.setActive(false);

        User savedUser = userRepository.save(user);

        if (file != null && !file.isEmpty()) {
            String imagePath = uploadImage(file, dto.getContactPerson());
            dto.setAddress( imagePath);
        }

        Logistics_Officer officer = officerMapper.toOfficerEntity(dto, savedUser, policeStation);
        if (file != null && !file.isEmpty()) {
            officer.setImage(dto.getAddress());
        }

        Logistics_Officer savedOfficer = officerRepository.save(officer);

        authService.sendVerificationEmail(savedOfficer.getUser().getEmail());

        return officerMapper.convertTOResponseDTO(savedOfficer);
    }

    @Override
    @Transactional
    public LogisticsOfficerResponseDTO update(Long id, LogisticsOfficerRequestDTO dto, MultipartFile file) {
        Logistics_Officer officer = officerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Logistics Officer instance not found at ID: " + id));

        PoliceStation policeStation = officer.getPoliceStation();
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station node mismatch"));
            officer.setPoliceStation(policeStation);
        }

        User user = officer.getUser();
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

        officer.setContactPerson(dto.getContactPerson());
        officer.setAddress(dto.getAddress());
        officer.setNidNumber(dto.getNidNumber());
        officer.setPassportNumber(dto.getPassportNumber());
        officer.setDesignation(dto.getDesignation());

        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            officer.setDob(LocalDate.parse(dto.getDob()));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().isBlank()) {
            officer.setJoiningDate(LocalDate.parse(dto.getJoiningDate()));
        }
        if (dto.getGender() != null) {
            officer.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null) {
            officer.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        if (file != null && !file.isEmpty()) {
            String newImagePath = uploadImage(file, dto.getContactPerson());
            officer.setImage( newImagePath);
        }

        return officerMapper.convertTOResponseDTO(officerRepository.save(officer));
    }

    @Override
    @Transactional(readOnly = true)
    public List<LogisticsOfficerResponseDTO> findAll() {
        return officerRepository.findAllWithDetails().stream()
                .map(officerMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<LogisticsOfficerResponseDTO> getById(Long id) {
        return officerRepository.findById(id).map(officerMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Logistics_Officer officer = officerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target Logistics Officer instance key mapping missing"));
        officerRepository.delete(officer);
        if (officer.getUser() != null) {
            userRepository.delete(officer.getUser());
        }
    }

    @Override
    public Optional<LogisticsOfficerResponseDTO> findUserById(Long id) {
        return officerRepository.findByUserId(id).map(officerMapper::convertTOResponseDTO);
    }

    private String uploadImage(MultipartFile file, String name) {
        try {
            Path path = Paths.get(uploadDir, "logistics_officer");
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = "officer";
            if (name != null) {
                cleanedName = name.trim()
                        .replaceAll("[^a-zA-Z0-9\\s]", "")
                        .replaceAll("\\s+", "_");
            }
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;
        } catch (Exception e) {
            throw new RuntimeException("Officer layout deployment file system fault: " + e.getMessage());
        }
    }



}