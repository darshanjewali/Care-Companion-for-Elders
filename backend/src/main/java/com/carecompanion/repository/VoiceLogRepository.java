package com.carecompanion.repository;

import com.carecompanion.model.VoiceLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VoiceLogRepository extends JpaRepository<VoiceLog, Long> {
}

