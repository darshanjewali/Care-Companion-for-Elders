package com.carecompanion.controller;

import com.carecompanion.model.Medication;
import com.carecompanion.service.CurrentUserService;
import com.carecompanion.service.MedicationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/medications")
@CrossOrigin
public class MedicationController {
    private final MedicationService medicationService;
    private final CurrentUserService currentUserService;

    public MedicationController(MedicationService medicationService, CurrentUserService currentUserService) {
        this.medicationService = medicationService;
        this.currentUserService = currentUserService;
    }

    @PostMapping
    public Medication add(@RequestBody Medication medication) {
        return medicationService.add(medication);
    }

    @GetMapping("/{elderId}")
    public List<Medication> byElder(@PathVariable Long elderId) {
        return medicationService.byElder(elderId);
    }

    @GetMapping("/me")
    public List<Medication> mine() {
        return medicationService.byElder(currentUserService.getCurrentUserId());
    }

    @PutMapping("/{id}/taken")
    public Medication markTaken(@PathVariable Long id) {
        return medicationService.markTaken(id);
    }
}
