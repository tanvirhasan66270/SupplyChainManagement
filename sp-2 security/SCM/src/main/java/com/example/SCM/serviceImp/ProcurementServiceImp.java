package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.ProcurementMapper;
import com.example.SCM.dto.request.ProcurementRequestDTO;
import com.example.SCM.dto.response.ProcurementResponseDTO;
import com.example.SCM.entity.Procurement;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.example.SCM.repository.ProcurementRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.ProcurementService;
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
public class ProcurementServiceImp implements ProcurementService {

    private final ProcurementRepository procurementRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final ProcurementMapper procurementMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Override
    @Transactional
    public ProcurementResponseDTO save(ProcurementRequestDTO dto, MultipartFile file) {
        if (dto.getPassword() == null || dto.getPassword().isEmpty()) {
            throw new RuntimeException("Credential password mandatory for procurement node recruitment!");
        }

        if (dto.getPassportNumber() != null && !dto.getPassportNumber().isBlank() && procurementRepository.existsByPassportNumber(dto.getPassportNumber())) {
            throw new RuntimeException("This Passport number is already registered under another officer!");
        }
        if (procurementRepository.existsByNidNumber(dto.getNidNumber())) {
            throw new RuntimeException("This NID number is already registered under another officer!");
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
        user.setRole(Role.PROCUREMENT);
        user.setActive(false);
        user.setPoliceStation(policeStation);

        User savedUser = userRepository.save(user);

        String imagePath = null;
        if (file != null && !file.isEmpty()) {
            imagePath = uploadImage(file, dto.getName());
        }

        Procurement procurement = procurementMapper.toProcurementEntity(dto, savedUser, policeStation);
        if (imagePath != null) {
            procurement.setImage(imagePath);
        }

        Procurement savedProcurement = procurementRepository.save(procurement);

        authService.sendVerificationEmail(savedProcurement.getUser().getEmail());

        return procurementMapper.convertTOResponseDTO(savedProcurement);
    }

    @Override
    @Transactional
    public ProcurementResponseDTO update(Long id, ProcurementRequestDTO dto, MultipartFile file) {
        Procurement procurement = procurementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Procurement profile instance missing at ID: " + id));

        PoliceStation policeStation = procurement.getPoliceStation();
        if (dto.getPoliceStationId() != null) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Police Station node mismatch"));
            procurement.setPoliceStation(policeStation);
        }

        User user = procurement.getUser();
        if (user != null) {
            user.setName(dto.getName());
            user.setEmail(dto.getEmail());
            user.setPhoneNumber(dto.getPhone());
            if (dto.getPassword() != null && !dto.getPassword().isBlank()) {
                user.setPassword(passwordEncoder.encode(dto.getPassword()));
            }
            user.setPoliceStation(policeStation);
            userRepository.save(user);
        }

        procurement.setAddress(dto.getAddress());
        procurement.setNidNumber(dto.getNidNumber());
        procurement.setPassportNumber(dto.getPassportNumber());
        procurement.setDesignation(dto.getDesignation());
        procurement.setActive(dto.isActive());

        if (dto.getDob() != null && !dto.getDob().isBlank()) {
            procurement.setDob(LocalDate.parse(dto.getDob()));
        }
        if (dto.getJoiningDate() != null && !dto.getJoiningDate().isBlank()) {
            procurement.setJoiningDate(LocalDate.parse(dto.getJoiningDate()));
        }
        if (dto.getGender() != null && !dto.getGender().isBlank()) {
            procurement.setGender(GenderStatus.valueOf(dto.getGender().toUpperCase()));
        }
        if (dto.getLanguage() != null && !dto.getLanguage().isBlank()) {
            procurement.setLanguage(LanguageStatus.valueOf(dto.getLanguage().toUpperCase()));
        }

        if (file != null && !file.isEmpty()) {
            String newImagePath = uploadImage(file, dto.getName());
            procurement.setImage(newImagePath);
        }

        return procurementMapper.convertTOResponseDTO(procurementRepository.save(procurement));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ProcurementResponseDTO> findAll() {
        return procurementRepository.findAllWithDetails().stream()
                .map(procurementMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<ProcurementResponseDTO> getById(Long id) {
        return procurementRepository.findById(id).map(procurementMapper::convertTOResponseDTO);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Procurement procurement = procurementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target Procurement pointer missing"));
        procurementRepository.delete(procurement);
        if (procurement.getUser() != null) {
            userRepository.delete(procurement.getUser());
        }
    }

    @Override
    public Optional<ProcurementResponseDTO> findUserById(Long id) {
        return procurementRepository.findByUserId(id).map(procurementMapper::convertTOResponseDTO);
    }

    private String uploadImage(MultipartFile file, String name) {
        try {
            Path path = Paths.get(uploadDir, "procurement");
            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();
            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = "procurement";
            if (name != null) {
                cleanedName = name.trim()
                        .replaceAll("[^a-zA-Z0-9\\s]", "")
                        .replaceAll("\\s+", "_");
            }
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;
        } catch (Exception e) {
            throw new RuntimeException("Procurement storage node allocation failure: " + e.getMessage());
        }
    }
}