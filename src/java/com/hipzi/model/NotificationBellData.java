package com.hipzi.model;

import java.util.Collections;
import java.util.List;

public class NotificationBellData {
    private final List<Notification> notifications;
    private final int unreadCount;

    public NotificationBellData(List<Notification> notifications, int unreadCount) {
        this.notifications = notifications == null ? Collections.emptyList() : notifications;
        this.unreadCount = unreadCount;
    }

    public List<Notification> getNotifications() {
        return notifications;
    }

    public int getUnreadCount() {
        return unreadCount;
    }
}
