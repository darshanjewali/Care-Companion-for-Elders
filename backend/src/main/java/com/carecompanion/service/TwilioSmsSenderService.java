package com.carecompanion.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Service
public class TwilioSmsSenderService implements SmsSenderService {
    private final RestTemplate restTemplate;

    @Value("${app.otp.sms.mode:debug}")
    private String smsMode;

    @Value("${app.otp.sms.twilio.account-sid:}")
    private String accountSid;

    @Value("${app.otp.sms.twilio.auth-token:}")
    private String authToken;

    @Value("${app.otp.sms.twilio.from-number:}")
    private String fromNumber;

    public TwilioSmsSenderService(RestTemplateBuilder builder) {
        this.restTemplate = builder.build();
    }

    @Override
    public void sendSms(String toPhone, String message) {
        if (!"twilio".equalsIgnoreCase(smsMode)) {
            return;
        }
        if (accountSid.isBlank() || authToken.isBlank() || fromNumber.isBlank()) {
            throw new IllegalStateException("Twilio SMS config missing. Set account-sid/auth-token/from-number.");
        }

        String url = "https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json";
        MultiValueMap<String, String> body = new LinkedMultiValueMap<>();
        body.add("To", toPhone);
        body.add("From", fromNumber);
        body.add("Body", message);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        String creds = accountSid + ":" + authToken;
        String basic = Base64.getEncoder().encodeToString(creds.getBytes(StandardCharsets.UTF_8));
        headers.set("Authorization", "Basic " + basic);

        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(body, headers);
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, request, String.class);
        if (!response.getStatusCode().is2xxSuccessful()) {
            throw new IllegalStateException("Failed to send SMS via Twilio: " + response.getStatusCode());
        }
    }
}

