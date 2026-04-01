package com.bmwparts.service;

import com.bmwparts.model.User;
import com.bmwparts.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service @Slf4j @RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User register(String email, String password, String fullName) {
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already registered");
        }
        String encoded = passwordEncoder.encode(password);
        User user = User.builder()
                .email(email)
                .passwordHash(encoded)
                .fullName(fullName)
                .build();
        return userRepository.save(user);
    }

    public Optional<User> login(String email, String password) {
        User user = userRepository.findByEmail(email)
                .orElse(null);
        if (user == null) {
            return Optional.empty();
        }
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            return Optional.empty();
        }
        return Optional.of(user);
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
}
