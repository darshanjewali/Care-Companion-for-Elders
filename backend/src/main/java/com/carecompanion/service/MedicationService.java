package com.carecompanion.service;

import com.carecompanion.model.Medication;
import com.carecompanion.repository.MedicationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicationService {
    private final MedicationRepository repository;

    public MedicationService(MedicationRepository repository) {
        this.repository = repository;
    }

    public Medication add(Medication medication) {
        return repository.save(medication);
    }

    public List<Medication> byElder(Long elderId) {
        return repository.findByElderId(elderId);
    }

    public Medication markTaken(Long id) {
        Medication medication = repository.findById(id).orElseThrow();
        medication.setTaken(true);
        return repository.save(medication);
    }
}
