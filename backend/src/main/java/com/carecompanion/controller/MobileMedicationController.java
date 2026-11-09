package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.Medication;
import com.carecompanion.repository.MedicationRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/medicines")
public class MobileMedicationController {
    private final CurrentUserService currentUserService;
    private final MedicationRepository medicationRepository;

    public MobileMedicationController(CurrentUserService currentUserService,
                                       MedicationRepository medicationRepository) {
        this.currentUserService = currentUserService;
        this.medicationRepository = medicationRepository;
    }

    @GetMapping("/today")
    public List<MobileDtos.TodayMedicineDto> today() {
        Long elderId = currentUserService.getCurrentUserId();
        LocalDate today = LocalDate.now();
        LocalDateTime now = LocalDateTime.now();

        return medicationRepository.findByElderIdAndReminderDate(elderId, today).stream()
                .sorted(Comparator.comparing(Medication::getReminderTime, Comparator.nullsLast(String::compareTo)))
                .map(m -> {
                    String status = computeStatus(m, now);
                    return new MobileDtos.TodayMedicineDto(
                            m.getId(),
                            m.getMedicineName(),
                            m.getReminderTime(),
                            status
                    );
                })
                .collect(Collectors.toList());
    }

    @PostMapping
    public MobileDtos.TodayMedicineDto add(@RequestBody MobileDtos.MedicineCreateRequest request) {
        Long elderId = currentUserService.getCurrentUserId();
        Medication medication = new Medication();
        medication.setElderId(elderId);
        medication.setMedicineName(request.name());
        medication.setDosage(request.dosage());
        medication.setInstructions(request.instructions());
        medication.setReminderTime(request.reminderTime());
        medication.setReminderDate(
                request.reminderDate() == null || request.reminderDate().isBlank()
                        ? LocalDate.now()
                        : LocalDate.parse(request.reminderDate())
        );
        medication.setTaken(false);
        Medication saved = medicationRepository.save(medication);
        return new MobileDtos.TodayMedicineDto(saved.getId(), saved.getMedicineName(), saved.getReminderTime(), "pending");
    }

    @PostMapping("/taken")
    public MobileDtos.EmergencyResponse taken(@RequestBody MobileDtos.MedicineTakenRequest request) {
        Medication m = medicationRepository.findById(request.medicineId()).orElseThrow(() -> new IllegalArgumentException("Medicine not found"));
        m.setTaken(true);
        medicationRepository.save(m);
        return new MobileDtos.EmergencyResponse(String.valueOf(m.getId()), "ok");
    }

    private String computeStatus(Medication m, LocalDateTime now) {
        if (m.isTaken()) return "taken";
        if (m.getReminderTime() == null) return "pending";

        try {
            LocalTime time = LocalTime.parse(m.getReminderTime(), DateTimeFormatter.ofPattern("HH:mm"));
            LocalDateTime due = LocalDateTime.of(m.getReminderDate(), time);
            LocalDateTime missedAfter = due.plusMinutes(30); // grace window
            if (now.isAfter(missedAfter)) return "missed";
        } catch (Exception ignored) {
        }
        return "pending";
    }
}

