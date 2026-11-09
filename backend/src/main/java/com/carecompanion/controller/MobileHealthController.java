package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.HealthRecord;
import com.carecompanion.repository.HealthRecordRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Optional;

@RestController
@RequestMapping("/api/health")
public class MobileHealthController {
    private final CurrentUserService currentUserService;
    private final HealthRecordRepository healthRecordRepository;

    public MobileHealthController(CurrentUserService currentUserService,
                                    HealthRecordRepository healthRecordRepository) {
        this.currentUserService = currentUserService;
        this.healthRecordRepository = healthRecordRepository;
    }

    @GetMapping("/latest")
    public MobileDtos.HealthLatestResponse latest() {
        Long elderId = currentUserService.getCurrentUserId();
        Optional<HealthRecord> latest = healthRecordRepository.findTop1ByElderIdOrderByRecordedAtDesc(elderId);
        if (latest.isEmpty()) {
            return new MobileDtos.HealthLatestResponse("N/A", "N/A", 0);
        }

        HealthRecord r = latest.get();
        String bp = (r.getSystolicBp() == null || r.getDiastolicBp() == null)
                ? "N/A"
                : r.getSystolicBp() + "/" + r.getDiastolicBp();

        return new MobileDtos.HealthLatestResponse(
                bp,
                r.getBloodSugar() == null ? "N/A" : String.valueOf(r.getBloodSugar().intValue()),
                r.getHeartRate() == null ? 0 : r.getHeartRate()
        );
    }
}

