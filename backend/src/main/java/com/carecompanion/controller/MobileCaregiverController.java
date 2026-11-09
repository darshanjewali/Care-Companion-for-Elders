package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.CaregiverLink;
import com.carecompanion.model.HealthRecord;
import com.carecompanion.model.Medication;
import com.carecompanion.model.User;
import com.carecompanion.repository.AlertRepository;
import com.carecompanion.repository.CaregiverLinkRepository;
import com.carecompanion.repository.HealthRecordRepository;
import com.carecompanion.repository.MedicationRepository;
import com.carecompanion.repository.UserRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/caregiver")
public class MobileCaregiverController {
    private final CurrentUserService currentUserService;
    private final CaregiverLinkRepository caregiverLinkRepository;
    private final UserRepository userRepository;
    private final HealthRecordRepository healthRecordRepository;
    private final MedicationRepository medicationRepository;
    private final AlertRepository alertRepository;

    public MobileCaregiverController(CurrentUserService currentUserService,
                                      CaregiverLinkRepository caregiverLinkRepository,
                                      UserRepository userRepository,
                                      HealthRecordRepository healthRecordRepository,
                                      MedicationRepository medicationRepository,
                                      AlertRepository alertRepository) {
        this.currentUserService = currentUserService;
        this.caregiverLinkRepository = caregiverLinkRepository;
        this.userRepository = userRepository;
        this.healthRecordRepository = healthRecordRepository;
        this.medicationRepository = medicationRepository;
        this.alertRepository = alertRepository;
    }

    @GetMapping("/patient-data")
    public List<MobileDtos.CaregiverPatientDto> patientData() {
        Long caregiverId = currentUserService.getCurrentUserId();

        List<CaregiverLink> links = caregiverLinkRepository.findByCaregiverIdAndStatus(caregiverId, "ACTIVE");
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        return links.stream().map(link -> {
            Long elderId = link.getElderId();
            User elder = userRepository.findById(elderId).orElseThrow();

            Optional<HealthRecord> latest = healthRecordRepository.findTop1ByElderIdOrderByRecordedAtDesc(elderId);
            MobileDtos.HealthLatestResponse latestDto = latest
                    .map(this::toLatestDto)
                    .orElse(new MobileDtos.HealthLatestResponse("N/A", "N/A", 0));

            int missed = (int) medicationRepository.findByElderIdAndReminderDate(elderId, today).stream()
                    .filter(m -> isMissed(m, now))
                    .count();

            int sosCount24h = (int) alertRepository.findByElderIdOrderByCreatedAtDesc(elderId).stream()
                    .filter(a -> "SOS".equalsIgnoreCase(a.getType()))
                    .filter(a -> a.getCreatedAt() != null && a.getCreatedAt().isAfter(now.minusHours(24)))
                    .count();

            return new MobileDtos.CaregiverPatientDto(elderId, elder.getFullName(), latestDto, missed, sosCount24h);
        }).collect(Collectors.toList());
    }

    private MobileDtos.HealthLatestResponse toLatestDto(HealthRecord r) {
        String bp = (r.getSystolicBp() == null || r.getDiastolicBp() == null) ? "N/A" : r.getSystolicBp() + "/" + r.getDiastolicBp();
        String sugar = r.getBloodSugar() == null ? "N/A" : String.valueOf(r.getBloodSugar().intValue());
        int hr = r.getHeartRate() == null ? 0 : r.getHeartRate();
        return new MobileDtos.HealthLatestResponse(bp, sugar, hr);
    }

    private boolean isMissed(Medication m, LocalDateTime now) {
        if (m.isTaken()) return false;
        if (m.getReminderTime() == null || m.getReminderDate() == null) return false;
        try {
            LocalTime time = LocalTime.parse(m.getReminderTime(), DateTimeFormatter.ofPattern("HH:mm"));
            LocalDateTime due = LocalDateTime.of(m.getReminderDate(), time).plusMinutes(30);
            return now.isAfter(due);
        } catch (Exception ignored) {
            return false;
        }
    }
}

