package com.carecompanion.controller;

import com.carecompanion.model.Alert;
import com.carecompanion.service.CurrentUserService;
import com.carecompanion.service.AlertService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/alerts")
@CrossOrigin
public class AlertController {
    private final AlertService alertService;
    private final CurrentUserService currentUserService;

    public AlertController(AlertService alertService, CurrentUserService currentUserService) {
        this.alertService = alertService;
        this.currentUserService = currentUserService;
    }

    @PostMapping("/sos")
    public Alert sos(@RequestBody Alert alert) {
        return alertService.sos(alert);
    }

    @PostMapping("/push")
    public Alert pushNotification(@RequestBody Alert alert) {
        return alertService.push(alert);
    }

    @GetMapping("/{elderId}")
    public List<Alert> byElder(@PathVariable Long elderId) {
        return alertService.byElder(elderId);
    }

    @GetMapping("/me")
    public List<Alert> mine() {
        return alertService.byElder(currentUserService.getCurrentUserId());
    }
}
