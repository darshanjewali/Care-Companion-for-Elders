package com.carecompanion.service;

import com.carecompanion.model.Alert;
import com.carecompanion.repository.AlertRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AlertService {
    private final AlertRepository repository;

    public AlertService(AlertRepository repository) {
        this.repository = repository;
    }

    public Alert sos(Alert alert) {
        alert.setType("SOS");
        return repository.save(alert);
    }

    public Alert push(Alert alert) {
        return repository.save(alert);
    }

    public List<Alert> byElder(Long elderId) {
        return repository.findByElderIdOrderByCreatedAtDesc(elderId);
    }
}
