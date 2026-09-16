package com.example.SCM.service;



import com.example.SCM.dto.request.AdminRequest;
import com.example.SCM.dto.response.AdminResponse;
import org.springframework.stereotype.Service;

import java.util.List;
@Service
public interface AdminService {
    AdminResponse create(AdminRequest request);
    AdminResponse update(Long id, AdminRequest request);
    AdminResponse getById(Long id);
    List<AdminResponse> getAll();
//    void delete(Long id);
}