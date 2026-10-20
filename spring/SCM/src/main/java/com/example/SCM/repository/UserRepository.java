package com.example.SCM.repository;

import com.example.SCM.entity.User;
import com.example.SCM.role.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {



    @Query("SELECT u FROM User u WHERE u.role IN :roles")
    List<User> findUsersByRoles(@Param("roles") List<Role> roles);

    Optional<User> findByEmail(String email);

    List<User> findByRole(Role role);
}