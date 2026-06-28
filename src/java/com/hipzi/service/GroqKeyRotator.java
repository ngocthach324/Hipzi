package com.hipzi.service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

public class GroqKeyRotator {
    private static final long COOLDOWN_MILLIS = 60_000L;
    private final List<KeyState> keys = new ArrayList<>();
    private final AtomicInteger cursor = new AtomicInteger(0);

    public GroqKeyRotator(String csvKeys) {
        if (csvKeys != null) {
            for (String raw : csvKeys.split(",")) {
                String key = raw == null ? "" : raw.trim();
                if (!key.isEmpty()) {
                    keys.add(new KeyState(key));
                }
            }
        }
    }

    public synchronized Lease nextLease() {
        if (keys.isEmpty()) {
            return null;
        }
        long now = Instant.now().toEpochMilli();
        int size = keys.size();
        for (int i = 0; i < size; i++) {
            int index = Math.floorMod(cursor.getAndIncrement(), size);
            KeyState state = keys.get(index);
            if (state.cooldownUntil <= now) {
                return new Lease(index, state.key);
            }
        }
        return null;
    }

    public synchronized void markLimited(int index) {
        if (index >= 0 && index < keys.size()) {
            keys.get(index).cooldownUntil = Instant.now().toEpochMilli() + COOLDOWN_MILLIS;
        }
    }

    public boolean hasKeys() {
        return !keys.isEmpty();
    }

    public static class Lease {
        private final int index;
        private final String key;

        Lease(int index, String key) {
            this.index = index;
            this.key = key;
        }

        public int getIndex() { return index; }
        public String getKey() { return key; }
    }

    private static class KeyState {
        private final String key;
        private long cooldownUntil;

        KeyState(String key) {
            this.key = key;
        }
    }
}
