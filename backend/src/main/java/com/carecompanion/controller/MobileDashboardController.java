package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.HealthRecord;
import com.carecompanion.model.Medication;
import com.carecompanion.repository.HealthRecordRepository;
import com.carecompanion.repository.MedicationRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
public class MobileDashboardController {
    private final CurrentUserService currentUserService;
    private final HealthRecordRepository healthRecordRepository;
    private final MedicationRepository medicationRepository;

    public MobileDashboardController(CurrentUserService currentUserService,
                                      HealthRecordRepository healthRecordRepository,
                                      MedicationRepository medicationRepository) {
        this.currentUserService = currentUserService;
        this.healthRecordRepository = healthRecordRepository;
        this.medicationRepository = medicationRepository;
    }

    @GetMapping
    public MobileDtos.DashboardResponse dashboard() {
        var user = currentUserService.getCurrentUser();
        var elderId = user.getId();

        LocalDate today = LocalDate.now();
        List<Medication> todaysMeds = medicationRepository.findByElderIdAndReminderDate(elderId, today);

        String nextMedicine = todaysMeds.stream()
                .filter(m -> !m.isTaken())
                .sorted(Comparator.comparing(this::safeParseTime))
                .map(Medication::getMedicineName)
                .findFirst()
                .orElse("No pending medicines");

        var latestHealthOpt = healthRecordRepository.findTop1ByElderIdOrderByRecordedAtDesc(elderId);
        String healthStatus = latestHealthOpt.map(this::computeHealthStatus).orElse("Stable");

        return new MobileDtos.DashboardResponse(user.getFullName(), nextMedicine, healthStatus);
    }

    private String computeHealthStatus(HealthRecord record) {
        // Simple safety thresholds (tune per clinical policy later).
        boolean risk =
                (record.getSystolicBp() != null && record.getSystolicBp() >= 140) ||
                (record.getDiastolicBp() != null && record.getDiastolicBp() >= 90) ||
                (record.getBloodSugar() != null && record.getBloodSugar() >= 180) ||
                (record.getHeartRate() != null && (record.getHeartRate() >= 110 || record.getHeartRate() <= 50));
        return risk ? "Unstable" : "Stable";
    }

    private LocalTime safeParseTime(Medication m) {
        try {
            return LocalTime.parse(m.getReminderTime(), DateTimeFormatter.ofPattern("HH:mm"));
        } catch (Exception ignored) {
            return LocalTime.MAX;
        }
    }
}

