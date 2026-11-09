package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.HealthRecord;
import com.carecompanion.repository.HealthRecordRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class MobileAiController {
    private final CurrentUserService currentUserService;
    private final HealthRecordRepository healthRecordRepository;

    @Value("${app.ml-service.base-url:http://localhost:8000}")
    private String mlServiceBaseUrl;

    public MobileAiController(CurrentUserService currentUserService,
                               HealthRecordRepository healthRecordRepository) {
        this.currentUserService = currentUserService;
        this.healthRecordRepository = healthRecordRepository;
    }

    @GetMapping("/health-prediction")
    public MobileDtos.AiRiskResponse predict() {
        Long elderId = currentUserService.getCurrentUserId();
        var latest = healthRecordRepository.findTop1ByElderIdOrderByRecordedAtDesc(elderId);
        if (latest.isEmpty()) {
            return new MobileDtos.AiRiskResponse("Low", "No recent data. Keep monitoring your health.");
        }

        HealthRecord r = latest.get();
        double inactivityHours = 0;
        if (r.getRecordedAt() != null) {
            inactivityHours = Duration.between(r.getRecordedAt(), LocalDateTime.now()).toMinutes() / 60.0;
        }

        // Call ML service, fallback to rule-based if unavailable.
        try {
            RestTemplate template = new RestTemplate();
            String url = mlServiceBaseUrl + "/risk-score";
            Map<String, Object> payload = new HashMap<>();
            payload.put("systolic_bp", r.getSystolicBp() == null ? 0 : r.getSystolicBp());
            payload.put("diastolic_bp", r.getDiastolicBp() == null ? 0 : r.getDiastolicBp());
            payload.put("blood_sugar", r.getBloodSugar() == null ? 0 : r.getBloodSugar());
            payload.put("heart_rate", r.getHeartRate() == null ? 0 : r.getHeartRate());
            payload.put("inactivity_hours", inactivityHours);

            @SuppressWarnings("unchecked")
            Map<String, Object> mlResp = template.postForObject(url, payload, Map.class);

            String riskLevel = String.valueOf(mlResp.getOrDefault("riskLevel", "LOW"));
            String recommendation = String.valueOf(mlResp.getOrDefault("recommendation", "Consult doctor if needed."));
            String risk = riskLevel.toUpperCase(Locale.ROOT).equals("HIGH")
                    ? "High"
                    : riskLevel.toUpperCase(Locale.ROOT).equals("MEDIUM")
                    ? "Medium"
                    : "Low";

            return new MobileDtos.AiRiskResponse(risk, recommendation);
        } catch (Exception ignored) {
            // Fallback rule-based risk.
            boolean high =
                    (r.getSystolicBp() != null && r.getSystolicBp() >= 160) ||
                    (r.getDiastolicBp() != null && r.getDiastolicBp() >= 100) ||
                    (r.getBloodSugar() != null && r.getBloodSugar() >= 250) ||
                    (r.getHeartRate() != null && (r.getHeartRate() >= 120 || r.getHeartRate() <= 45));
            boolean medium =
                    !high &&
                    ((r.getSystolicBp() != null && r.getSystolicBp() >= 140) ||
                     (r.getDiastolicBp() != null && r.getDiastolicBp() >= 90) ||
                     (r.getBloodSugar() != null && r.getBloodSugar() >= 180) ||
                     (r.getHeartRate() != null && (r.getHeartRate() >= 110 || r.getHeartRate() <= 50)));

            String risk = high ? "High" : (medium ? "Medium" : "Low");
            String suggestion = high ? "Consult doctor soon and monitor closely."
                    : medium ? "Consider doctor consultation if symptoms continue."
                    : "Continue daily monitoring and take medicines on time.";
            return new MobileDtos.AiRiskResponse(risk, suggestion);
        }
    }
}

