package com.carecompanion.service;

import com.carecompanion.model.HealthRecord;
import com.carecompanion.repository.HealthRecordRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class HealthService {
    private final HealthRecordRepository repository;

    public HealthService(HealthRecordRepository repository) {
        this.repository = repository;
    }

    public HealthRecord add(HealthRecord record) {
        return repository.save(record);
    }

    public List<HealthRecord> byElder(Long elderId) {
        return repository.findByElderIdOrderByRecordedAtDesc(elderId);
    }
}
