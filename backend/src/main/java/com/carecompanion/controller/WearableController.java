package com.carecompanion.controller;

import com.carecompanion.service.CurrentUserService;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/wearables")
public class WearableController {
    private final CurrentUserService currentUserService;

    private final Map<Long, String> connectedDeviceByUser = new ConcurrentHashMap<>();
    private final Map<Long, List<Map<String, Object>>> remindersByUser = new ConcurrentHashMap<>();
    private final Map<Long, Map<String, Object>> latestVitalsByUser = new ConcurrentHashMap<>();

    public WearableController(CurrentUserService currentUserService) {
        this.currentUserService = currentUserService;
    }

    @GetMapping("/status")
    public Map<String, Object> status() {
        Long userId = currentUserService.getCurrentUserId();
        String name = connectedDeviceByUser.get(userId);
        return Map.of(
                "connected", name != null,
                "deviceName", name == null ? "" : name
        );
    }

    @PostMapping("/connect")
    public Map<String, Object> connect(@RequestBody Map<String, Object> payload) {
        Long userId = currentUserService.getCurrentUserId();
        String deviceName = String.valueOf(payload.getOrDefault("deviceName", "Smart Watch"));
        connectedDeviceByUser.put(userId, deviceName);
        latestVitalsByUser.put(userId, createRandomVitalsPayload());
        return Map.of("connected", true, "deviceName", deviceName);
    }

    @PostMapping("/disconnect")
    public Map<String, Object> disconnect() {
        Long userId = currentUserService.getCurrentUserId();
        connectedDeviceByUser.remove(userId);
        latestVitalsByUser.remove(userId);
        return Map.of("connected", false);
    }

    @GetMapping("/reminders")
    public List<Map<String, Object>> reminders() {
        Long userId = currentUserService.getCurrentUserId();
        return remindersByUser.getOrDefault(userId, List.of());
    }

    @PostMapping("/reminders")
    public Map<String, Object> addReminder(@RequestBody Map<String, Object> payload) {
        Long userId = currentUserService.getCurrentUserId();
        List<Map<String, Object>> list = remindersByUser.computeIfAbsent(userId, k -> new ArrayList<>());
        long id = list.size() + 1L;
        Map<String, Object> row = Map.of(
                "id", id,
                "title", String.valueOf(payload.getOrDefault("title", "Medicine Reminder")),
                "time", String.valueOf(payload.getOrDefault("time", "08:00")),
                "repeatDaily", Boolean.parseBoolean(String.valueOf(payload.getOrDefault("repeatDaily", true)))
        );
        list.add(row);
        return row;
    }

    @GetMapping("/vitals/live")
    public Map<String, Object> liveVitals() {
        Long userId = currentUserService.getCurrentUserId();
        if (!connectedDeviceByUser.containsKey(userId)) {
            return Map.of("connected", false, "message", "No smartwatch connected");
        }

        // If no incoming telemetry, keep values alive with subtle random drift.
        Map<String, Object> current = latestVitalsByUser.computeIfAbsent(userId, k -> createRandomVitalsPayload());
        int hr = ((Number) current.getOrDefault("heartRate", 75)).intValue();
        int pulse = ((Number) current.getOrDefault("pulse", 75)).intValue();
        int spo2 = ((Number) current.getOrDefault("spo2", 98)).intValue();

        hr = clamp(hr + ThreadLocalRandom.current().nextInt(-2, 3), 55, 120);
        pulse = clamp(pulse + ThreadLocalRandom.current().nextInt(-2, 3), 55, 120);
        spo2 = clamp(spo2 + ThreadLocalRandom.current().nextInt(-1, 2), 90, 100);

        Map<String, Object> updated = Map.of(
                "heartRate", hr,
                "pulse", pulse,
                "spo2", spo2,
                "steps", ((Number) current.getOrDefault("steps", 0)).intValue() + ThreadLocalRandom.current().nextInt(0, 9),
                "calories", ((Number) current.getOrDefault("calories", 0)).intValue() + ThreadLocalRandom.current().nextInt(0, 3),
                "recordedAt", Instant.now().toString()
        );
        latestVitalsByUser.put(userId, updated);
        return Map.of("connected", true, "deviceName", connectedDeviceByUser.get(userId), "metrics", updated);
    }

    @PostMapping("/vitals")
    public Map<String, Object> ingestVitals(@RequestBody Map<String, Object> payload) {
        Long userId = currentUserService.getCurrentUserId();
        if (!connectedDeviceByUser.containsKey(userId)) {
            throw new IllegalStateException("Connect smartwatch before sending telemetry");
        }
        Map<String, Object> merged = Map.of(
                "heartRate", intOr(payload.get("heartRate"), 75),
                "pulse", intOr(payload.get("pulse"), intOr(payload.get("heartRate"), 75)),
                "spo2", intOr(payload.get("spo2"), 98),
                "steps", intOr(payload.get("steps"), 0),
                "calories", intOr(payload.get("calories"), 0),
                "recordedAt", Instant.now().toString()
        );
        latestVitalsByUser.put(userId, merged);
        return Map.of("saved", true, "metrics", merged);
    }

    private Map<String, Object> createRandomVitalsPayload() {
        return Map.of(
                "heartRate", ThreadLocalRandom.current().nextInt(68, 86),
                "pulse", ThreadLocalRandom.current().nextInt(68, 86),
                "spo2", ThreadLocalRandom.current().nextInt(95, 100),
                "steps", ThreadLocalRandom.current().nextInt(0, 200),
                "calories", ThreadLocalRandom.current().nextInt(0, 40),
                "recordedAt", Instant.now().toString()
        );
    }

    private int intOr(Object value, int fallback) {
        if (value == null) return fallback;
        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (Exception ignored) {
            return fallback;
        }
    }

    private int clamp(int value, int min, int max) {
        return Math.max(min, Math.min(max, value));
    }
}

