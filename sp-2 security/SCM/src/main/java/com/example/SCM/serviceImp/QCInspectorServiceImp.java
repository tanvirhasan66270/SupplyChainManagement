package com.example.SCM.serviceImp;

import com.example.SCM.auth.AuthService;
import com.example.SCM.dto.mapper.QCInspectorMapper;
import com.example.SCM.dto.request.QCInspectorRequestDTO;
import com.example.SCM.dto.response.QCInspectorResponseDTO;
import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.QCInspector;
import com.example.SCM.entity.User;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.QCInspectorRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.role.Role;
import com.example.SCM.service.QCInspectorService;
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
public class QCInspectorServiceImp implements QCInspectorService {

    private final QCInspectorRepository qcInspectorRepository;
    private final UserRepository userRepository;
    private final PoliceStationRepository policeStationRepository;
    private final QCInspectorMapper qcInspectorMapper;
    private final PasswordEncoder passwordEncoder;
    private final AuthService authService;

    @Value("${image.upload.dir}")
    private String uploadDir;

    @Transactional
    @Override
    public QCInspectorResponseDTO save(QCInspectorRequestDTO dto, MultipartFile image) {

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
        user.setActive(false);
        user.setRole(Role.QC_INSPECTOR);
        user.setPoliceStation(policeStation);

        User savedUser = userRepository.save(user);

        QCInspector inspector = qcInspectorMapper.toQCInspectorEntity(dto, savedUser, policeStation);

        if (image != null && !image.isEmpty()) {
            String imagePath = uploadImage(image, dto.getName());
            inspector.setImage(imagePath);
        }

        QCInspector savedInspector = qcInspectorRepository.save(inspector);
        authService.sendVerificationEmail(savedInspector.getUser().getEmail());

        return qcInspectorMapper.convertTOResponseDTO(savedInspector);
    }

    @Transactional
    @Override
    public QCInspectorResponseDTO update(Long id, QCInspectorRequestDTO dto, MultipartFile image) {

        QCInspector inspector = qcInspectorRepository.findByIdWithDetails(id)
                .orElseThrow(() -> new RuntimeException("QC Inspector not found with ID: " + id));

        PoliceStation policeStation = inspector.getPoliceStation();
        if (dto.getPoliceStationId() != null && (policeStation == null || !dto.getPoliceStationId().equals(policeStation.getId()))) {
            policeStation = policeStationRepository.findById(dto.getPoliceStationId())
                    .orElseThrow(() -> new RuntimeException("Selected Police Station not found with ID: " + dto.getPoliceStationId()));
        }

        qcInspectorMapper.updateEntity(dto, inspector, policeStation);

        if (image != null && !image.isEmpty()) {
            String newImagePath = uploadImage(image, dto.getName());
            inspector.setImage( newImagePath);
        }

        User user = inspector.getUser();
        if (user != null) {
            user.setName(dto.getName());
            user.setEmail(dto.getEmail());
            user.setPhoneNumber(dto.getPhone());
            user.setPoliceStation(policeStation);

            if (dto.getPassword() != null && !dto.getPassword().trim().isEmpty()) {
                user.setPassword(passwordEncoder.encode(dto.getPassword()));
            }
            userRepository.save(user);
        }

        return qcInspectorMapper.convertTOResponseDTO(qcInspectorRepository.save(inspector));
    }

    @Override
    @Transactional(readOnly = true)
    public List<QCInspectorResponseDTO> findAll() {
        return qcInspectorRepository.findAllInspectors().stream()
                .map(qcInspectorMapper::convertTOResponseDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<QCInspectorResponseDTO> getById(Long id) {
        return qcInspectorRepository.findByIdWithDetails(id)
                .map(qcInspectorMapper::convertTOResponseDTO);
    }

    @Transactional
    @Override
    public void delete(Long id) {
        QCInspector inspector = qcInspectorRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("QC Inspector not found with ID: " + id));

        User user = inspector.getUser();
        qcInspectorRepository.delete(inspector);

        if (user != null) {
            userRepository.delete(user);
        }
    }

    @Override
    public Optional<QCInspectorResponseDTO> findUserById(Long id) {
        return qcInspectorRepository.findByUserId(id).map(qcInspectorMapper::convertTOResponseDTO);
    }

    private String uploadImage(MultipartFile file, String name) {
        try {
            Path path = Paths.get(uploadDir, "qc_inspector");

            if (!Files.exists(path)) {
                Files.createDirectories(path);
            }

            String ext = "";
            String original = file.getOriginalFilename();

            if (original != null && original.contains(".")) {
                ext = original.substring(original.lastIndexOf("."));
            }

            String cleanedName = "inspector";
            if (name != null) {
                cleanedName = name.trim()
                        .replaceAll("[^a-zA-Z0-9\\s]", "")
                        .replaceAll("\\s+", "_");
            }
            String fileName = cleanedName + "_" + UUID.randomUUID() + ext;

            Files.copy(file.getInputStream(), path.resolve(fileName), StandardCopyOption.REPLACE_EXISTING);
            return fileName;

        } catch (Exception e) {
            throw new RuntimeException("Image upload failed for QC Inspector profile: " + e.getMessage(), e);
        }
    }
}