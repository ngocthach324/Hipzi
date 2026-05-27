package com.hipzi.service;

import com.hipzi.dao.RememberMeTokenDao;
import com.hipzi.dao.UserDao;
import com.hipzi.dao.UserRoleDao;
import com.hipzi.model.User;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;

public class RememberMeService {

    public static final String COOKIE_NAME = "HIPZI_REMEMBER";
    private static final int MAX_AGE_SECONDS = 30 * 24 * 60 * 60;

    private final RememberMeTokenDao tokenDao = new RememberMeTokenDao();
    private final UserDao userDao = new UserDao();
    private final UserRoleDao userRoleDao = new UserRoleDao();
    private final SecureRandom secureRandom = new SecureRandom();

    public void issueRememberCookie(User user, HttpServletRequest request, HttpServletResponse response) {
        if (user == null || user.getId() == null) return;

        String selector = randomToken(18);
        String validator = randomToken(32);
        String validatorHash = sha256(validator);
        Instant expiresAt = Instant.now().plus(30, ChronoUnit.DAYS);

        if (!tokenDao.createToken(user.getId(), selector, validatorHash, expiresAt)) {
            return;
        }

        Cookie cookie = new Cookie(COOKIE_NAME, selector + ":" + validator);
        cookie.setPath(cookiePath(request));
        cookie.setHttpOnly(true);
        cookie.setSecure(request.isSecure());
        cookie.setMaxAge(MAX_AGE_SECONDS);
        response.addCookie(cookie);
    }

    public User consumeRememberCookie(HttpServletRequest request, HttpServletResponse response) {
        Cookie cookie = findCookie(request);
        if (cookie == null || cookie.getValue() == null) return null;

        String[] parts = cookie.getValue().split(":", 2);
        if (parts.length != 2 || parts[0].isEmpty() || parts[1].isEmpty()) {
            clearRememberCookie(request, response);
            return null;
        }

        String selector = parts[0];
        String validatorHash = sha256(parts[1]);
        String userId = tokenDao.findValidUserId(selector, validatorHash);
        if (userId == null) {
            tokenDao.revokeBySelector(selector);
            clearRememberCookie(request, response);
            return null;
        }

        User user = userDao.findById(userId);
        if (user == null || !"active".equalsIgnoreCase(user.getAccountStatus())) {
            tokenDao.revokeBySelector(selector);
            clearRememberCookie(request, response);
            return null;
        }

        user.setRoles(userRoleDao.getRolesByUserId(user.getId()));
        return user;
    }

    public void clearRememberCookie(HttpServletRequest request, HttpServletResponse response) {
        Cookie existing = findCookie(request);
        if (existing != null && existing.getValue() != null) {
            String[] parts = existing.getValue().split(":", 2);
            if (parts.length > 0 && !parts[0].isEmpty()) {
                tokenDao.revokeBySelector(parts[0]);
            }
        }

        Cookie expired = new Cookie(COOKIE_NAME, "");
        expired.setPath(cookiePath(request));
        expired.setHttpOnly(true);
        expired.setSecure(request.isSecure());
        expired.setMaxAge(0);
        response.addCookie(expired);
    }

    private Cookie findCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) {
            if (COOKIE_NAME.equals(cookie.getName())) {
                return cookie;
            }
        }
        return null;
    }

    private String cookiePath(HttpServletRequest request) {
        String contextPath = request.getContextPath();
        return contextPath == null || contextPath.isEmpty() ? "/" : contextPath;
    }

    private String randomToken(int byteLength) {
        byte[] bytes = new byte[byteLength];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(hash);
        } catch (Exception e) {
            throw new IllegalStateException("Could not hash remember-me token", e);
        }
    }
}
