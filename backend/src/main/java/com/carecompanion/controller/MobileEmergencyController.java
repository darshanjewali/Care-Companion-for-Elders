package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.Alert;
import com.carecompanion.model.LocationLog;
import com.carecompanion.repository.AlertRepository;
import com.carecompanion.repository.LocationLogRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class MobileEmergencyController {
    private final CurrentUserService currentUserService;
    private final AlertRepository alertRepository;
    private final LocationLogRepository locationLogRepository;

    public MobileEmergencyController(CurrentUserService currentUserService,
                                      AlertRepository alertRepository,
                                      LocationLogRepository locationLogRepository) {
        this.currentUserService = currentUserService;
        this.alertRepository = alertRepository;
        this.locationLogRepository = locationLogRepository;
    }

    @PostMapping("/emergency")
    public MobileDtos.EmergencyResponse emergency(@RequestBody MobileDtos.EmergencyRequest request) {
        Long elderId = currentUserService.getCurrentUserId();

        var loc = request.location();
        String locationStr = loc == null ? null : (loc.lat() + "," + loc.lng());

        Alert alert = new Alert();
        alert.setElderId(elderId);
        alert.setType("SOS");
        alert.setMessage(request.message() + " | healthStatus=" + request.healthStatus());
        alert.setLocation(locationStr);
        alert.setAcknowledged(false);
        Alert saved = alertRepository.save(alert);

        LocationLog log = new LocationLog();
        log.setElderId(elderId);
        if (loc != null) {
            log.setLatitude(loc.lat());
            log.setLongitude(loc.lng());
        }
        log.setEventSource("MOBILE_SOS");
        locationLogRepository.save(log);

        return new MobileDtos.EmergencyResponse(String.valueOf(saved.getId()), "sent");
    }
}

