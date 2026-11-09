package com.carecompanion.controller;

import com.carecompanion.model.Alert;
import com.carecompanion.model.HealthRecord;
import com.carecompanion.service.HealthService;
import com.carecompanion.repository.AlertRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/health-records")
@CrossOrigin
public class HealthController {
    private final HealthService healthService;
    private final CurrentUserService currentUserService;
    private final AlertRepository alertRepository;

    public HealthController(HealthService healthService,
                             CurrentUserService currentUserService,
                             AlertRepository alertRepository) {
        this.healthService = healthService;
        this.currentUserService = currentUserService;
        this.alertRepository = alertRepository;
    }

    @PostMapping
    public HealthRecord add(@RequestBody HealthRecord record) {
        // Security: bind record to the authenticated user (elderId).
        record.setElderId(currentUserService.getCurrentUserId());

        // Save first.
        HealthRecord saved = healthService.add(record);

        // Then evaluate thresholds for caregiver alerts.
        createHealthAlertsIfNeeded(saved);

        return saved;
    }

    private void createHealthAlertsIfNeeded(HealthRecord r) {
        List<String> reasons = new ArrayList<>();
        if (r.getSystolicBp() != null && r.getSystolicBp() >= 160) reasons.add("High systolic BP");
        if (r.getDiastolicBp() != null && r.getDiastolicBp() >= 100) reasons.add("High diastolic BP");
        if (r.getBloodSugar() != null && r.getBloodSugar() >= 250) reasons.add("High blood sugar");
        if (r.getHeartRate() != null && (r.getHeartRate() >= 120 || r.getHeartRate() <= 45)) reasons.add("Abnormal heart rate");

        if (reasons.isEmpty()) return;

        Alert alert = new Alert();
        alert.setElderId(r.getElderId());
        alert.setType("HEALTH_ALERT");
        alert.setMessage(String.join(", ", reasons));
        alert.setLocation(null);
        alert.setAcknowledged(false);
        alertRepository.save(alert);
    }

    @GetMapping("/{elderId}")
    public List<HealthRecord> byElder(@PathVariable Long elderId) {
        return healthService.byElder(elderId);
    }

    @GetMapping("/me")
    public List<HealthRecord> mine() {
        return healthService.byElder(currentUserService.getCurrentUserId());
    }
}
