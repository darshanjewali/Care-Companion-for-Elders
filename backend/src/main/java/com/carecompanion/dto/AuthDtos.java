package com.carecompanion.dto;

import com.carecompanion.model.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class AuthDtos {
    public record RegisterRequest(
            @NotBlank String fullName,
            @NotBlank @Email String email,
            String phone,
            @NotBlank String password,
            @NotNull Role role
    ) {}

    // Supports both:
    // - OTP login: phone + otp
    // - Email/password login: email + password
    // Validation is handled in service (to keep backward compatibility).
    public record LoginRequest(String phone, String otp, String email, String password, String role) {}

    public record UserSummary(String name, String role) {}

    public record AuthResponse(String token, UserSummary user) {}

    public record OtpRequest(String phone) {}
    public record OtpResponse(boolean sent, String message, String otp) {}
}
