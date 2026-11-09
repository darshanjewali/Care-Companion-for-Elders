package com.carecompanion.service;

import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OtpManager {
    private static class OtpEntry {
        final String otp;
        final Instant expiresAt;

        OtpEntry(String otp, Instant expiresAt) {
            this.otp = otp;
            this.expiresAt = expiresAt;
        }
    }

    private final Map<String, OtpEntry> store = new ConcurrentHashMap<>();

    public void storeOtp(String phone, String otp, long ttlSeconds) {
        store.put(phone, new OtpEntry(otp, Instant.now().plusSeconds(ttlSeconds)));
    }

    public boolean verifyOtp(String phone, String candidate) {
        OtpEntry entry = store.get(phone);
        if (entry == null) return false;
        if (Instant.now().isAfter(entry.expiresAt)) {
            store.remove(phone);
            return false;
        }
        boolean ok = entry.otp.equals(candidate);
        if (ok) {
            store.remove(phone);
        }
        return ok;
    }
}

