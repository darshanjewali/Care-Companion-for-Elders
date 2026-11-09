package com.carecompanion.controller;

import com.carecompanion.dto.MobileDtos;
import com.carecompanion.model.VoiceLog;
import com.carecompanion.repository.VoiceLogRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class MobileVoiceController {
    private final CurrentUserService currentUserService;
    private final VoiceLogRepository voiceLogRepository;

    public MobileVoiceController(CurrentUserService currentUserService,
                                  VoiceLogRepository voiceLogRepository) {
        this.currentUserService = currentUserService;
        this.voiceLogRepository = voiceLogRepository;
    }

    @PostMapping("/voice-command")
    public MobileDtos.VoiceCommandResponse voice(@RequestBody MobileDtos.VoiceCommandRequest request) {
        Long userId = currentUserService.getCurrentUserId();
        String command = request.command() == null ? "" : request.command().trim().toLowerCase();
        String lang = request.lang() == null ? "en" : request.lang();

        String intent;
        String message;

        if (command.contains("medicine") || command.contains("remind")) {
            intent = "OPEN_MEDICINES";
            message = "Opening medicine reminders.";
        } else if (command.contains("sos") || command.contains("emergency")) {
            intent = "TRIGGER_SOS";
            message = "Emergency mode. Please press the SOS button if needed.";
        } else if (command.contains("call")) {
            intent = "TRIGGER_CALL";
            message = "I can help you call your caregiver or doctor.";
        } else if (command.contains("bp") || command.contains("sugar") || command.contains("health")) {
            intent = "OPEN_HEALTH";
            message = "Opening health tracker.";
        } else {
            intent = "GENERAL_REPLY";
            message = "You can say: 'Remind medicines', 'Open health', or 'SOS'.";
        }

        VoiceLog log = new VoiceLog();
        log.setUserId(userId);
        log.setCommandText(request.command());
        log.setLang(lang);
        log.setIntent(intent);
        log.setMessage(message);
        voiceLogRepository.save(log);

        return new MobileDtos.VoiceCommandResponse(intent, message);
    }
}

