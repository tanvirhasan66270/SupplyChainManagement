package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.CommercialOfficerMapper;
import com.example.SCM.dto.request.CommercialOfficerRequestDTO;
import com.example.SCM.dto.response.CommercialOfficerResponseDTO;
import com.example.SCM.entity.CommercialOfficer;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.example.SCM.repository.CommercialOfficerRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.CommercialOfficerService;
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
public class CommercialOfficerServiceImp implements CommercialOfficerService {

    private final CommercialOfficerRepository officerRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final CommercialOfficerMapper officerMapper;
    private final AuthService authService;
    private final PasswordEncoder passwordEncoder;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Transactional
    @Override
    public CommercialOfficerResponseDTO save(CommercialOfficerRequestDTO dto, MultipartFile file) {
        if (dto.getPassword() == null || dto.getPassword().isEmpty()) {
            throw new RuntimeException("Credential password mandatory for commercial workstation deployment!");
        }

        if (dto.getPassportNumber() != null && officerRepository.existsByPassportNumber(dto.getPassportNumber())) {
            throw new RuntimeException("This Passport number is already registered under another commercial officer!");
        }
        if (officerRepository.existsByNidNumber(dto.getNidNumber())) {
            throw new RuntimeException("This NID number is already registered under another commercial officer!");
        }

        // 1. Save associated user identity profile
        User user = new User();
        user.setName(dto.getName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setActive(false);
        user.setRole(Role.COMMERCIAL_OFFICER);
        User savedUser = userRepository.save(user);

        PoliceStation policeStation = null;
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station not resolved with ID: " + dto.getPoliceStationId()));
        }

        // 2. Map DTO descriptors onto core Entity infrastructure
        CommercialOfficer officer = officerMapper.toOfficerEntity(dto, savedUser, policeStation);

        if (file != null && !file.isEmpty()) {
            String uploadedFileName = uploadImage(file, dto.getName());
            officer.setImage(uploadedFileName);
        }

        CommercialOfficer savedOfficer = officerRepository.save(officer);
        authService.sendVerificationEmail(savedOfficer.getUser().getEmail());

        return officerMapper.convertTOResponseDTO(savedOfficer);
    }

    @Transactional
    @Override
    public CommercialOfficerResponseDTO update(Long id, CommercialOfficerRequestDTO dto, MultipartFile file) {
        CommercialOfficer officer = officerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Commercial Officer instance not found at ID: " + id));

        User user = officer.getUser();
        if (user != null) {
            user.setName(dto.getName());
            user.setEmail(dto.getEmail());
            user.setPhoneNumber(dto.getPhone());
            if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
                user.setPassword(passwordEncoder.encode(dto.getPassword()));
            }
            userRepository.save(user);
        }

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
            String newImagePath = uploadImage(file, dto.getName());
            officer.setImage(newImagePath);
        }

        if (dto.getPoliceStationId() != null) {
            PoliceStation policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station node mismatch"));
            officer.setPoliceStation(policeStation);
        }

        return officerMapper.convertTOResponseDTO(officerRepository.save(officer));
    }

    @Transactional(readOnly = true)
    @Override
    public List<CommercialOfficerResponseDTO> findAll() {
        return officerRepository.findAllWithDetails()
                .stream()
                .map(officerMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public Optional<CommercialOfficerResponseDTO> getById(Long id) {
        return officerRepository.findById(id)
                .map(officerMapper::convertTOResponseDTO);
    }

    @Transactional
    @Override
    public void delete(Long id) {
        CommercialOfficer officer = officerRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target Commercial Officer key tracking missing"));
        officerRepository.delete(officer);
    }

    @Override
    public Optional<CommercialOfficerResponseDTO> findUserById(Long id) {
        return officerRepository.findByUserId(id)
                .map(officerMapper::convertTOResponseDTO);
    }

    private String uploadImage(MultipartFile file, String name) {
        try {
            Path path = Paths.get(uploadDir, "commercial_officer");

            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();

            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            // উইন্ডোজ ফাইল সিস্টেমের অবৈধ ক্যারেক্টার ক্লিনআপ
            String cleanedName = name.trim()
                    .replaceAll("[\\\\/:*?\"<>|]", "_")
                    .replaceAll("\\s+", "_");
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Commercial file system node upload fault: " + e.getMessage());
        }
    }
}