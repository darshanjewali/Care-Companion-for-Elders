package com.carecompanion.repository;

import com.carecompanion.model.Alert;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlertRepository extends JpaRepository<Alert, Long> {
    List<Alert> findByElderIdOrderByCreatedAtDesc(Long elderId);
}
