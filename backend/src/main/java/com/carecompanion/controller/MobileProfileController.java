package com.carecompanion.controller;

import com.carecompanion.model.CaregiverLink;
import com.carecompanion.repository.CaregiverLinkRepository;
import com.carecompanion.repository.UserRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/profile")
public class MobileProfileController {
    private final CurrentUserService currentUserService;
    private final CaregiverLinkRepository caregiverLinkRepository;
    private final UserRepository userRepository;

    public MobileProfileController(CurrentUserService currentUserService,
                                   CaregiverLinkRepository caregiverLinkRepository,
                                   UserRepository userRepository) {
        this.currentUserService = currentUserService;
        this.caregiverLinkRepository = caregiverLinkRepository;
        this.userRepository = userRepository;
    }

    @PostMapping("/link-caregiver")
    public Map<String, String> link(@RequestBody Map<String, Object> payload) {
        Object elderIdObj = payload.get("elderId");
        Long elderId;

        if (elderIdObj != null) {
            elderId = Long.valueOf(String.valueOf(elderIdObj));
        } else {
            Object elderPhoneObj = payload.get("elderPhone");
            if (elderPhoneObj == null) {
                throw new IllegalArgumentException("Either elderId or elderPhone is required");
            }
            String elderPhone = String.valueOf(elderPhoneObj);
            elderId = userRepository.findByPhone(elderPhone)
                    .orElseThrow(() -> new IllegalArgumentException("No elder found for phone"))
                    .getId();
        }

        CaregiverLink link = new CaregiverLink();
        link.setElderId(elderId);
        link.setCaregiverId(currentUserService.getCurrentUserId());
        link.setStatus("ACTIVE");
        caregiverLinkRepository.save(link);

        return Map.of("status", "linked");
    }
}

