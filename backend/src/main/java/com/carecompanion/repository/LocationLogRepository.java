package com.carecompanion.repository;

import com.carecompanion.model.LocationLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LocationLogRepository extends JpaRepository<LocationLog, Long> {
    List<LocationLog> findByElderIdOrderByCreatedAtDesc(Long elderId);
}

