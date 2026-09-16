package com.example.SCM.serviceImp;

import com.example.SCM.dto.mapper.AdminMapper;
import com.example.SCM.dto.request.AdminRequest;
import com.example.SCM.dto.response.AdminResponse;
import com.example.SCM.entity.Admin;
import com.example.SCM.entity.User;
import com.example.SCM.repository.AdminRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private final AdminRepository adminRepository;
    private final UserRepository userRepository;
    private final AdminMapper adminMapper;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    @Override
    public AdminResponse create(AdminRequest request) {
        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhone());
        user.setActive(true);
        user.setRole(com.example.SCM.role.Role.ADMIN);

        if (request.getPassword() != null && !request.getPassword().isBlank()) {
            user.setPassword(passwordEncoder.encode(request.getPassword()));
        }
        User savedUser = userRepository.save(user);

        Admin admin = new Admin();
        admin.setName(request.getName());
        admin.setEmail(request.getEmail());
        admin.setPhone(request.getPhone());
        admin.setUser(savedUser);

        Admin savedAdmin = adminRepository.save(admin);

        return adminMapper.toResponse(savedAdmin);
    }

    @Transactional
    @Override
    public AdminResponse update(Long id, AdminRequest request) {
        Admin admin = adminRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Admin master record missing"));

        adminMapper.updateEntity(request, admin);

        User user = admin.getUser();
        if (user != null) {
            if (request.getName() != null) user.setName(request.getName());
            if (request.getEmail() != null) user.setEmail(request.getEmail());
            if (request.getPhone() != null) user.setPhoneNumber(request.getPhone());

            if (request.getPassword() != null && !request.getPassword().isBlank()) {
                user.setPassword(passwordEncoder.encode(request.getPassword()));
            }
            userRepository.save(user);
        }

        Admin updatedAdmin = adminRepository.save(admin);
        return adminMapper.toResponse(updatedAdmin);
    }

    @Transactional(readOnly = true)
    @Override
    public List<AdminResponse> getAll() {
        return adminRepository.findAll()
                .stream()
                .map(adminMapper::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    @Override
    public AdminResponse getById(Long id) {
        Admin admin = adminRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Target admin node index missing"));
        return adminMapper.toResponse(admin);
    }

//    @Transactional
//    @Override
//    public void delete(Long id) {
//        Admin admin = adminRepository.findById(id)
//                .orElseThrow(() -> new RuntimeException("Target admin node index missing"));
//
//        adminRepository.delete(admin);
//
//        if (admin.getUser() != null) {
//            userRepository.delete(admin.getUser());
//        }
//    }
}