package com.carecompanion.controller;

import com.carecompanion.model.Appointment;
import com.carecompanion.model.Prescription;
import com.carecompanion.repository.AppointmentRepository;
import com.carecompanion.repository.PrescriptionRepository;
import com.carecompanion.service.CurrentUserService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/appointments")
public class MobileAppointmentController {
    private final CurrentUserService currentUserService;
    private final AppointmentRepository appointmentRepository;
    private final PrescriptionRepository prescriptionRepository;

    public MobileAppointmentController(CurrentUserService currentUserService,
                                        AppointmentRepository appointmentRepository,
                                        PrescriptionRepository prescriptionRepository) {
        this.currentUserService = currentUserService;
        this.appointmentRepository = appointmentRepository;
        this.prescriptionRepository = prescriptionRepository;
    }

    @GetMapping("/me")
    public List<Appointment> myAppointments() {
        return appointmentRepository.findByElderId(currentUserService.getCurrentUserId());
    }

    public record AppointmentCreateRequest(Long doctorId, String appointmentTime, String reason, String status) {}

    @PostMapping("/me")
    public Appointment create(@RequestBody AppointmentCreateRequest request) {
        Appointment a = new Appointment();
        a.setElderId(currentUserService.getCurrentUserId());
        a.setDoctorId(request.doctorId());
        a.setAppointmentTime(LocalDateTime.parse(request.appointmentTime()));
        a.setReason(request.reason());
        a.setStatus(request.status() == null ? "BOOKED" : request.status());
        return appointmentRepository.save(a);
    }

    @PostMapping(path = "/{appointmentId}/prescription", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Map<String, Object> uploadPrescription(
            @PathVariable Long appointmentId,
            @RequestPart("file") MultipartFile file
    ) throws Exception {
        Appointment appointment = appointmentRepository.findById(appointmentId)
                .orElseThrow(() -> new IllegalArgumentException("Appointment not found"));

        if (!appointment.getElderId().equals(currentUserService.getCurrentUserId())) {
            throw new SecurityException("Not authorized to upload for this appointment");
        }

        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("file is required");
        }

        // Store in local filesystem (replace with S3 in production).
        Path uploadBase = Path.of("uploads", "prescriptions", String.valueOf(appointmentId));
        Files.createDirectories(uploadBase);

        String safeName = file.getOriginalFilename() == null ? "prescription" : file.getOriginalFilename().replaceAll("[^a-zA-Z0-9._-]", "_");
        Path target = uploadBase.resolve(safeName);
        Files.copy(file.getInputStream(), target, StandardCopyOption.REPLACE_EXISTING);

        Prescription p = new Prescription();
        p.setAppointmentId(appointmentId);
        p.setFileName(safeName);
        p.setContentType(file.getContentType());
        p.setFilePath(target.toString());
        Prescription saved = prescriptionRepository.save(p);

        return Map.of("prescriptionId", saved.getId(), "filePath", saved.getFilePath(), "status", "uploaded");
    }
}

