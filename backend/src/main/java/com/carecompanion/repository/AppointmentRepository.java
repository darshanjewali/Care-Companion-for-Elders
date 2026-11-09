package com.carecompanion.repository;

import com.carecompanion.model.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {
    List<Appointment> findByElderId(Long elderId);
}
