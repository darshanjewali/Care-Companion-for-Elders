package com.carecompanion.controller;

import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin
public class AiController {
    @PostMapping("/suggestions")
    public Map<String, String> suggestions(@RequestBody Map<String, Object> payload) {
        String suggestion = "Maintain hydration, take medicines on schedule, and share abnormal vitals with your doctor.";
        return Map.of(
                "status", "generated",
                "suggestion", suggestion,
                "note", "Template AI suggestion. Integrate with an LLM provider for production."
        );
    }
}
