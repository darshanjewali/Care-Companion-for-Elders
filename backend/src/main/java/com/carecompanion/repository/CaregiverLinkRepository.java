package com.carecompanion.repository;

import com.carecompanion.model.CaregiverLink;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CaregiverLinkRepository extends JpaRepository<CaregiverLink, Long> {
    List<CaregiverLink> findByCaregiverIdAndStatus(Long caregiverId, String status);
}

