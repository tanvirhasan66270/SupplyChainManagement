package com.example.SCM.dto.Seeder;

import com.example.SCM.dto.request.AdminRequest;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class AdminSeeder implements CommandLineRunner {

    private final AdminService adminService;
    private final UserRepository userRepository;

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.findByEmail("admin@scm.com").isPresent()) {
            return;
        }

        AdminRequest admin = new AdminRequest();
        admin.setName("System Admin");
        admin.setEmail("admin@scm.com");
        admin.setPhone("01999999999");
        admin.setPassword("123456");

        adminService.create(admin);

    }
}