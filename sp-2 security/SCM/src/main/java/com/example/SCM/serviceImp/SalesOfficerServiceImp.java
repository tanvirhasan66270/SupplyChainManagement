package com.example.SCM.serviceImp;



import com.example.SCM.Util.MailService;
import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.SalesOfficerMapper;
import com.example.SCM.dto.request.SalesOfficerRequestDTO;
import com.example.SCM.dto.response.SalesOfficerResponseDTO;
import com.example.SCM.entity.SalesOfficer;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.enumClass.GenderStatus;
import com.example.SCM.enumClass.LanguageStatus;
import com.example.SCM.repository.SalesOfficerRepository;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.SalesOfficerService;
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

public class SalesOfficerServiceImp implements SalesOfficerService {



    private final SalesOfficerRepository officerRepository;

    private final UserRepository userRepository;

    private final PoliceStationRepository policeStationRepository;

    private final SalesOfficerMapper officerMapper;

    private final MailService mailService;

    private final PasswordEncoder passwordEncoder;

    private final AuthService authService;







    @Value("${image.upload.dir}")

    private String uploadDir;



    @Override

    @Transactional

    public SalesOfficerResponseDTO save(SalesOfficerRequestDTO dto, MultipartFile file) {



        if (dto.getPassword() == null || dto.getPassword().trim().isEmpty()) {

            throw new RuntimeException("Credential password mandatory for secure identity allocation!");

        }



        if (officerRepository.existsByNidNumber(dto.getNidNumber())) {

            throw new RuntimeException("This NID number is already assigned to another staff profile!");

        }



        PoliceStation policeStation = null;

        if (dto.getPoliceStationId() != null) {

            policeStation = policeStationRepository.findById(dto.getPoliceStationId())

                    .orElseThrow(() -> new RuntimeException("Police Station node missing with ID: " + dto.getPoliceStationId()));

        }



        User user = new User();
        user.setName(dto.getName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRole(Role.SALES_OFFICER);
        user.setPoliceStation(policeStation);
        user.setActive(false);
        User savedUser = userRepository.save(user);

        if (file != null && !file.isEmpty()) {

            String imagePath = uploadImage(file, dto.getName());

            dto.setAddress( imagePath);

        }



        SalesOfficer officer = officerMapper.toOfficerEntity(dto, savedUser, policeStation);

        if (file != null && !file.isEmpty()) {

            officer.setImage(dto.getAddress());

        }

        SalesOfficer savedOfficer = officerRepository.save(officer);


        authService.sendVerificationEmail(savedOfficer.getUser().getEmail());

        return officerMapper.convertTOResponseDTO(savedOfficer);

    }



    @Override

    @Transactional

    public SalesOfficerResponseDTO update(Long id, SalesOfficerRequestDTO dto, MultipartFile file) {

        SalesOfficer officer = officerRepository.findById(id)

                .orElseThrow(() -> new RuntimeException("Sales Officer instance mismatch at key index: " + id));



        PoliceStation policeStation = officer.getPoliceStation();

        if (dto.getPoliceStationId() != null) {

            policeStation = policeStationRepository.findById(dto.getPoliceStationId())

                    .orElseThrow(() -> new RuntimeException("Police Station link failure"));

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



        officer.setAddress(dto.getAddress());

        officer.setNidNumber(dto.getNidNumber());

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



        return officerMapper.convertTOResponseDTO(officerRepository.save(officer));

    }



    @Override

    @Transactional(readOnly = true)

    public List<SalesOfficerResponseDTO> findAll() {

        return officerRepository.findAllWithDetails().stream()

                .map(officerMapper::convertTOResponseDTO)

                .collect(Collectors.toList());

    }



    @Override

    @Transactional(readOnly = true)

    public Optional<SalesOfficerResponseDTO> getById(Long id) {

        return officerRepository.findById(id).map(officerMapper::convertTOResponseDTO);

    }



    @Override

    @Transactional

    public void delete(Long id) {

        SalesOfficer officer = officerRepository.findById(id)

                .orElseThrow(() -> new RuntimeException("Target operational block pointer missing"));

        officerRepository.delete(officer);

        if (officer.getUser() != null) {

            userRepository.delete(officer.getUser());

        }

    }

    @Override
    public Optional<SalesOfficerResponseDTO> findUserById(Long id) {
        return officerRepository.findByUserId(id).map(officerMapper::convertTOResponseDTO);
    }


    private String uploadImage(MultipartFile file, String name) {

        try {

            Path path = Paths.get(uploadDir, "sales_officer");

            if (!Files.exists(path)) {

                Files.createDirectories(path);

            }



            String ext = "";

            String original = file.getOriginalFilename();

            if (original != null && original.contains(".")) {

                ext = original.substring(original.lastIndexOf("."));

            }



            String cleanedName = "sales_officer";

            if (name != null) {

                cleanedName = name.trim()

                        .replaceAll("[^a-zA-Z0-9\\s]", "")

                        .replaceAll("\\s+", "_");

            }

            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;



            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);

            return fileName;

        } catch (Exception e) {

            throw new RuntimeException("Sales staff filesystem attachment deployment failure: " + e.getMessage());

        }

    }





}