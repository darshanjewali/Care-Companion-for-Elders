package com.carecompanion.service;

import com.carecompanion.model.Appointment;
import com.carecompanion.repository.AppointmentRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AppointmentService {
    private final AppointmentRepository repository;

    public AppointmentService(AppointmentRepository repository) {
        this.repository = repository;
    }

    public Appointment create(Appointment appointment) {
        return repository.save(appointment);
    }

    public List<Appointment> byElder(Long elderId) {
        return repository.findByElderId(elderId);
    }
}
