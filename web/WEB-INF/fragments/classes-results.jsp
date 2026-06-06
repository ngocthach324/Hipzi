<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.hipzi.model.Classroom"%>
<%
    List<Classroom> classrooms = (List<Classroom>) request.getAttribute("classrooms");
    if (classrooms == null || classrooms.isEmpty()) {
%>
    <div class="empty-state">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#ccc" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <h3>Không tìm thấy lớp học</h3>
        <p>Hiện chưa có lớp học nào phù hợp với tiêu chí lọc. Hãy thử chọn môn học hoặc khối lớp khác.</p>
    </div>
<%
    } else {
        for (Classroom cls : classrooms) {
            String statusLabel = cls.getStatusLabel();
            String classCode = cls.getClassCode();
            boolean hasClassCode = classCode != null && !classCode.trim().isEmpty();
%>
        <div class="material-card class-card" style="padding: 1.5rem; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
                <div class="material-card-header" style="margin-bottom: 0.75rem;">
                    <div>
                        <span class="subject-badge" style="background: #d1fae5; color: #059669;"><%= cls.getSubject() %></span>
                    </div>
                    <% if (hasClassCode) { %>
                        <span style="font-size:0.75rem; font-weight:800; color:var(--primary); border: 1px solid var(--primary); background:#ecfdf5; padding:0.18rem 0.55rem; border-radius:999px;">
                            Mã: <%= classCode %>
                        </span>
                    <% } else { %>
                    <span style="font-size: 0.75rem; font-weight: 600; padding: 2px 8px; border-radius: 12px; background-color: <%= "Đang mở".equalsIgnoreCase(statusLabel) ? "#dcfce7" : "#fef9c3" %>; color: <%= "Đang mở".equalsIgnoreCase(statusLabel) ? "#15803d" : "#a16207" %>;">
                        <%= statusLabel %>
                    </span>
                    <% } %>
                </div>
                <h3 class="material-title" style="font-size: 1.15rem; margin-bottom: 0.5rem;"><%= cls.getTitle() %></h3>
                <p class="teacher-name" style="font-weight: 600; color: #334155; margin-bottom: 1rem;">GV: <%= cls.getTeacherName() %></p>

                <div style="background: #f8fafc; padding: 0.75rem; border-radius: 8px; margin-bottom: 1.25rem; font-size: 0.85rem; color: #475569;">
                    <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.25rem;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                        <span>Lịch: <strong><%= cls.getSchedule() %></strong></span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle></svg>
                        <span>Sĩ số: <strong><%= cls.getStudentCount() %> học viên</strong></span>
                    </div>
                </div>
            </div>

            <div class="material-card-footer" style="padding: 0; border: none;">
                <a href="<%= request.getContextPath() %>/class-detail?id=<%= cls.getId() %>" class="btn btn-primary btn-full" style="background: #059669; border-color: #059669; color: #ffffff; font-weight: 600; border-radius: 9999px;">Tham gia lớp</a>
            </div>
        </div>
<%
        }
    }
%>
