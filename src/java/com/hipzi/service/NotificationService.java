package com.hipzi.service;

import com.hipzi.dao.NotificationDao;
import com.hipzi.dao.UserDao;
import com.hipzi.model.Notification;
import java.util.List;

public class NotificationService {
    private final NotificationDao notificationDao = new NotificationDao();
    private final UserDao userDao = new UserDao();

    public boolean sendToUser(String userId, String title, String message, String type) {
        Notification n = new Notification();
        n.setUserId(userId);
        n.setTitle(title);
        n.setMessage(message);
        n.setType(type != null ? type : "info");
        return notificationDao.insert(n);
    }

    public int broadcastToAll(String title, String message, String type) {
        List<String> allUserIds = userDao.listAllIds();
        int successCount = 0;
        for (String userId : allUserIds) {
            if (sendToUser(userId, title, message, type)) {
                successCount++;
            }
        }
        return successCount;
    }

    public List<Notification> getRecentNotifications(String userId, int limit) {
        return notificationDao.listByUserId(userId, limit);
    }

    public int getUnreadCount(String userId) {
        return notificationDao.countUnread(userId);
    }

    public boolean markAsRead(String notificationId) {
        return notificationDao.markAsRead(notificationId);
    }

    public boolean markAllAsRead(String userId) {
        return notificationDao.markAllAsRead(userId);
    }
}
