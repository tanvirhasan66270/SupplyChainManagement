package com.example.SCM.service;

import com.example.SCM.entity.User;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public interface UserService {

    User save(User u);
    List<User> findAll();
    Optional<User> getById(Long id);
    void delete(Long id);
}
