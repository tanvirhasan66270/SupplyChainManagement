package com.example.SCM.serviceImp;

import com.example.SCM.entity.User;
import com.example.SCM.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor

public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

       @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

           User user=userRepository.findByEmail(username)
                   .orElseThrow(()->new UsernameNotFoundException(
                           "User Not found with Email"+username
                   ));

           if (!user.isActive()){

               throw new DisabledException(
                       "User Account is inactive please contact Manager"
               );
           }

           return user;
    }
}
