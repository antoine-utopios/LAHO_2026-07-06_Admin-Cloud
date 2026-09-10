package fr.gharrowbm.springapitestingnosecurity.services;

import com.github.benmanes.caffeine.cache.Cache;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Service
public class BruteForceService {
    private final Cache<String, AtomicInteger> attempsCache;
    private final Cache<String, Boolean> blockedCache;

    private static final int MAX_ATTEMPS = 5;
    private static final int BLOCK_MINUTES = 1;
    private static final int ATTEMPS_MINUTES = 15;

    public BruteForceService() {
        attempsCache = Caffeine.newBuilder()
                .expireAfterWrite(ATTEMPS_MINUTES, TimeUnit.MINUTES)
                .build();

        blockedCache = Caffeine.newBuilder()
                .expireAfterWrite(BLOCK_MINUTES, TimeUnit.MINUTES)
                .build();
    }

    public void loginFailed(String key) {
        AtomicInteger attemps = attempsCache.get(key, k -> new AtomicInteger(0));

        int v = attemps.incrementAndGet();

        if (v >= MAX_ATTEMPS) {
            blockedCache.put(key, true);
            attempsCache.invalidate(key);
        } else {
            attempsCache.put(key, attemps);
        }
    }

    public boolean isBlocked(String key) {
        Boolean isBlocked = blockedCache.getIfPresent(key);
        return isBlocked != null && isBlocked;
    }

    public void loginSuccess(String key) {
        attempsCache.invalidate(key);
        blockedCache.invalidate(key);
    }
}
