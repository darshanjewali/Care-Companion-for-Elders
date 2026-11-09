package com.carecompanion.controller;

import com.carecompanion.dto.AuthDtos;
import com.carecompanion.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {
    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public AuthDtos.AuthResponse register(@Valid @RequestBody AuthDtos.RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthDtos.AuthResponse login(@RequestBody AuthDtos.LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/request-otp")
    public AuthDtos.OtpResponse requestOtp(@RequestBody AuthDtos.OtpRequest request) {
        return authService.requestOtp(request);
    }
}
