package com.carecompanion.repository;

import com.carecompanion.model.Medication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.time.LocalDate;

public interface MedicationRepository extends JpaRepository<Medication, Long> {
    List<Medication> findByElderId(Long elderId);

    List<Medication> findByElderIdAndReminderDate(Long elderId, LocalDate reminderDate);
}
