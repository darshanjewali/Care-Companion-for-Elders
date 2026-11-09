package com.carecompanion.controller;

import com.carecompanion.model.Appointment;
import com.carecompanion.service.AppointmentService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/appointments")
@CrossOrigin
public class AppointmentController {
    private final AppointmentService appointmentService;

    public AppointmentController(AppointmentService appointmentService) {
        this.appointmentService = appointmentService;
    }

    @PostMapping
    public Appointment create(@RequestBody Appointment appointment) {
        return appointmentService.create(appointment);
    }

    @GetMapping("/{elderId}")
    public List<Appointment> byElder(@PathVariable Long elderId) {
        return appointmentService.byElder(elderId);
    }
}
