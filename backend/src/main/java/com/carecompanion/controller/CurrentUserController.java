package com.carecompanion.controller;

import com.carecompanion.model.User;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/me")
public class CurrentUserController {
    private final CurrentUserService currentUserService;

    public CurrentUserController(CurrentUserService currentUserService) {
        this.currentUserService = currentUserService;
    }

    @GetMapping
    public Map<String, Object> me() {
        User user = currentUserService.getCurrentUser();
        return Map.of(
                "id", user.getId(),
                "fullName", user.getFullName() == null ? "" : user.getFullName(),
                "email", user.getEmail() == null ? "" : user.getEmail(),
                "phone", user.getPhone() == null ? "" : user.getPhone(),
                "role", user.getRole().name()
        );
    }
}

