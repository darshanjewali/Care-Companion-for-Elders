package com.carecompanion.controller;

import com.carecompanion.repository.HealthRecordRepository;
import com.carecompanion.service.CurrentUserService;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayOutputStream;

@RestController
@RequestMapping("/api/reports")
@CrossOrigin
public class ReportController {
    private final HealthRecordRepository healthRecordRepository;
    private final CurrentUserService currentUserService;

    public ReportController(HealthRecordRepository healthRecordRepository, CurrentUserService currentUserService) {
        this.healthRecordRepository = healthRecordRepository;
        this.currentUserService = currentUserService;
    }

    @GetMapping("/elder/{elderId}/pdf")
    public ResponseEntity<byte[]> generatePdf(@PathVariable Long elderId) {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(output);
        PdfDocument pdf = new PdfDocument(writer);
        Document document = new Document(pdf);

        document.add(new Paragraph("Care Companion Health Report"));
        document.add(new Paragraph("Elder ID: " + elderId));
        healthRecordRepository.findByElderIdOrderByRecordedAtDesc(elderId).stream().limit(10)
                .forEach(r -> document.add(new Paragraph(
                        "Time: " + r.getRecordedAt() + " | HR: " + r.getHeartRate() + " | BP: "
                                + r.getSystolicBp() + "/" + r.getDiastolicBp() + " | Sugar: " + r.getBloodSugar()
                )));
        document.close();

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=health-report-" + elderId + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(output.toByteArray());
    }

    @GetMapping("/me/pdf")
    public ResponseEntity<byte[]> generateMyPdf() {
        return generatePdf(currentUserService.getCurrentUserId());
    }
}
