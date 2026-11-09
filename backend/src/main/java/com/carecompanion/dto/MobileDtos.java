package com.carecompanion.dto;

public class MobileDtos {
    public record DashboardResponse(String username, String nextMedicine, String healthStatus) {}

    public record HealthLatestResponse(String bp, String sugar, Integer heartRate) {}

    public record TodayMedicineDto(Long id, String name, String time, String status) {}

    public record MedicineTakenRequest(Long medicineId) {}

    public record MedicineCreateRequest(String name, String dosage, String reminderTime, String instructions, String reminderDate) {}

    public record EmergencyRequest(Location location, String healthStatus, String message) {
        public record Location(double lat, double lng) {}
    }

    public record EmergencyResponse(String alertId, String status) {}

    public record VoiceCommandRequest(String command, String lang) {}
    public record VoiceCommandResponse(String intent, String message) {}

    public record AiRiskResponse(String risk, String suggestion) {}

    public record CaregiverPatientDto(
            Long elderId,
            String elderName,
            HealthLatestResponse latest,
            int missedMedsCount,
            int recentSosCount
    ) {}
}

