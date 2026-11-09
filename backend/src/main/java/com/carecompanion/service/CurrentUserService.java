package com.carecompanion.service;

import com.carecompanion.model.Role;
import com.carecompanion.model.User;
import com.carecompanion.repository.UserRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service
public class CurrentUserService {
    private final UserRepository userRepository;

    public CurrentUserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User getCurrentUser() {
        String subject = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(subject)
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found"));
    }

    public Long getCurrentUserId() {
        return getCurrentUser().getId();
    }

    public Role getCurrentRole() {
        return getCurrentUser().getRole();
    }
}

