package com.example.SCM.serviceImp;

import com.example.SCM.entity.PoliceStation;
import com.example.SCM.entity.User;
import com.example.SCM.repository.PoliceStationRepository;
import com.example.SCM.repository.UserRepository;
import com.example.SCM.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserServiceImp implements UserService {



    private final UserRepository userRepository;



    @Override
    @Transactional
    public User save(User u) {

        return userRepository.save(u);
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> findAll() {
        return userRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<User> getById(Long id) {
        return userRepository.findById(id);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        if (!userRepository.existsById(id)) {
            throw new RuntimeException("User not found with ID: " + id);
        }
        userRepository.deleteById(id);
    }
}
