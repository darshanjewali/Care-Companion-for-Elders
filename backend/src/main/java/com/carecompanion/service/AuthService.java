package com.carecompanion.service;

import com.carecompanion.dto.AuthDtos;
import com.carecompanion.model.User;
import com.carecompanion.repository.UserRepository;
import com.carecompanion.security.JwtService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;

@Service
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final OtpManager otpManager;
    private final SmsSenderService smsSenderService;

    private final SecureRandom secureRandom = new SecureRandom();

    @Value("${app.otp.dev-mode:true}")
    private boolean devMode;

    @Value("${app.otp.ttl-seconds:300}")
    private long otpTtlSeconds;

    @Value("${app.otp.sms.mode:debug}")
    private String smsMode;

    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                       AuthenticationManager authenticationManager, JwtService jwtService,
                       OtpManager otpManager, SmsSenderService smsSenderService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.otpManager = otpManager;
        this.smsSenderService = smsSenderService;
    }

    public AuthDtos.AuthResponse register(AuthDtos.RegisterRequest request) {
        User user = new User();
        user.setFullName(request.fullName());
        user.setEmail(request.email());
        if (request.phone() != null && !request.phone().isBlank()) {
            user.setPhone(request.phone());
        }
        user.setPassword(passwordEncoder.encode(request.password()));
        user.setRole(request.role());
        userRepository.save(user);
        return new AuthDtos.AuthResponse(
                jwtService.generateToken(user.getEmail()),
                new AuthDtos.UserSummary(user.getFullName(), user.getRole().name().toLowerCase())
        );
    }

    public AuthDtos.AuthResponse login(AuthDtos.LoginRequest request) {
        // OTP login path
        if (request.phone() != null && !request.phone().isBlank()) {
            String otp = request.otp();
            if (otp == null || !otpManager.verifyOtp(request.phone(), otp)) {
                throw new IllegalArgumentException("Invalid OTP");
            }

            User user = userRepository.findByPhone(request.phone()).orElseGet(() -> {
                if (!devMode) {
                    throw new IllegalArgumentException("User not found for phone");
                }
                // Dev-mode: auto-provision an ELDER user so the mobile app can be tested immediately.
                User created = new User();
                created.setPhone(request.phone());
                created.setEmail(request.phone() + "@otp.local");
                created.setFullName("Elder");
                created.setPassword(passwordEncoder.encode(java.util.UUID.randomUUID().toString()));
                var roleStr = request.role();
                com.carecompanion.model.Role roleToCreate;
                if (roleStr == null) {
                    roleToCreate = com.carecompanion.model.Role.ELDER;
                } else {
                    switch (roleStr.trim().toUpperCase()) {
                        case "CAREGIVER" -> roleToCreate = com.carecompanion.model.Role.CAREGIVER;
                        case "DOCTOR" -> roleToCreate = com.carecompanion.model.Role.DOCTOR;
                        case "ADMIN" -> roleToCreate = com.carecompanion.model.Role.ADMIN;
                        default -> roleToCreate = com.carecompanion.model.Role.ELDER;
                    }
                }
                created.setRole(roleToCreate);
                created.setFullName(
                        roleToCreate == com.carecompanion.model.Role.CAREGIVER ? "Caregiver" :
                        roleToCreate == com.carecompanion.model.Role.DOCTOR ? "Doctor" :
                        roleToCreate == com.carecompanion.model.Role.ADMIN ? "Admin" :
                        "Elder"
                );
                return created;
            });

            userRepository.save(user);

            return new AuthDtos.AuthResponse(
                    jwtService.generateToken(user.getEmail()),
                    new AuthDtos.UserSummary(user.getFullName(), user.getRole().name().toLowerCase())
            );
        }

        // Email/password login path (backward compatibility)
        if (request.email() == null || request.email().isBlank()) {
            throw new IllegalArgumentException("Missing login credentials");
        }
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return new AuthDtos.AuthResponse(
                jwtService.generateToken(user.getEmail()),
                new AuthDtos.UserSummary(user.getFullName(), user.getRole().name().toLowerCase())
        );
    }

    public AuthDtos.OtpResponse requestOtp(AuthDtos.OtpRequest request) {
        if (request.phone() == null || request.phone().isBlank()) {
            throw new IllegalArgumentException("Phone is required");
        }

        String otp = String.format("%06d", secureRandom.nextInt(1_000_000));
        otpManager.storeOtp(request.phone(), otp, otpTtlSeconds);

        String smsBody = "Your Care Companion OTP is " + otp + ". It expires in " + (otpTtlSeconds / 60) + " minutes.";
        smsSenderService.sendSms(request.phone(), smsBody);

        if ("twilio".equalsIgnoreCase(smsMode)) {
            return new AuthDtos.OtpResponse(true, "OTP sent to your mobile number.", null);
        }
        return new AuthDtos.OtpResponse(true, "OTP generated in debug mode.", otp);
    }
}
