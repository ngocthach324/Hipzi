package com.hipzi.util;

import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

@ServerEndpoint("/status-ws")
public class UserStatusWebSocket {
    
    // Map userId to set of active WebSocket sessions
    private static final Map<String, Set<Session>> userSessions = new ConcurrentHashMap<>();
    // Map session to userId for cleanup
    private static final Map<Session, String> sessionUserMap = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session) {
        // Just opened, wait for auth message
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        try {
            // Simple manual parsing to avoid dependency on external JSON libraries
            if (message.contains("\"type\":\"auth\"")) {
                String userId = extractValue(message, "userId");
                if (userId != null && !userId.trim().isEmpty()) {
                    userId = userId.trim();

                    String oldUserId = sessionUserMap.get(session);
                    if (oldUserId != null && !oldUserId.equals(userId)) {
                        removeSessionFromUser(session, oldUserId);
                    }

                    sessionUserMap.put(session, userId);
                    Set<Session> sessions = userSessions.computeIfAbsent(userId, k -> new CopyOnWriteArraySet<>());
                    boolean wasOffline = sessions.isEmpty();
                    sessions.add(session);
                    
                    sendCurrentStatuses(session);

                    if (wasOffline) {
                        broadcastStatus(userId, "online");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session) {
        String userId = sessionUserMap.remove(session);
        if (userId != null) {
            removeSessionFromUser(session, userId);
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        onClose(session);
    }

    private void broadcastStatus(String userId, String status) {
        // Manual JSON construction
        String message = String.format(
                "{\"type\":\"status\",\"userId\":\"%s\",\"status\":\"%s\"}",
                escapeJson(userId),
                escapeJson(status)
        );
        for (Set<Session> sessions : userSessions.values()) {
            for (Session s : sessions) {
                if (s.isOpen()) {
                    s.getAsyncRemote().sendText(message);
                }
            }
        }
    }

    private void removeSessionFromUser(Session session, String userId) {
        Set<Session> sessions = userSessions.get(userId);
        if (sessions != null) {
            sessions.remove(session);
            if (sessions.isEmpty()) {
                userSessions.remove(userId);
                broadcastStatus(userId, "offline");
            }
        }
    }

    private void sendCurrentStatuses(Session session) throws IOException {
        if (!session.isOpen()) return;

        StringBuilder message = new StringBuilder("{\"type\":\"bulk_status\",\"statuses\":{");
        boolean first = true;
        for (String onlineUserId : userSessions.keySet()) {
            if (!first) {
                message.append(',');
            }
            message.append('"')
                   .append(escapeJson(onlineUserId))
                   .append("\":\"online\"");
            first = false;
        }
        message.append("}}");

        session.getBasicRemote().sendText(message.toString());
    }

    private String extractValue(String json, String key) {
        String pattern = "\"" + key + "\":\"";
        int start = json.indexOf(pattern);
        if (start == -1) return null;
        start += pattern.length();
        int end = json.indexOf("\"", start);
        if (end == -1) return null;
        return json.substring(start, end);
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    public static boolean isUserOnline(String userId) {
        return userId != null && userSessions.containsKey(userId);
    }
}
