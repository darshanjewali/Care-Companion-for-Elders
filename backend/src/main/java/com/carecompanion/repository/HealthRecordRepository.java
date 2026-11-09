package com.carecompanion.repository;

import com.carecompanion.model.HealthRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface HealthRecordRepository extends JpaRepository<HealthRecord, Long> {
    List<HealthRecord> findByElderIdOrderByRecordedAtDesc(Long elderId);

    Optional<HealthRecord> findTop1ByElderIdOrderByRecordedAtDesc(Long elderId);
}
