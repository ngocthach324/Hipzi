<%@ page pageEncoding="UTF-8" %>
<%
    java.util.List<com.hipzi.model.TeachingSchedule> allSchedules = 
        (java.util.List<com.hipzi.model.TeachingSchedule>) request.getAttribute("teacherSchedules");
    if (allSchedules == null) allSchedules = new java.util.ArrayList<>();

    int weekOffset = 0;
    try {
        if (request.getParameter("weekOffset") != null) {
            weekOffset = Integer.parseInt(request.getParameter("weekOffset"));
        }
    } catch (NumberFormatException ignored) {}

    java.time.LocalDate today = java.time.LocalDate.now();
    java.time.LocalDate startOfWeek = today.plusWeeks(weekOffset).with(java.time.temporal.TemporalAdjusters.previousOrSame(java.time.DayOfWeek.MONDAY));
    
    java.util.Map<Integer, java.util.List<com.hipzi.model.TeachingSchedule>> weekSchedules = new java.util.HashMap<>();
    for (int i = 0; i < 7; i++) {
        weekSchedules.put(i, new java.util.ArrayList<>());
    }
    
    java.time.LocalDate endOfWeek = startOfWeek.plusDays(7);
    for (com.hipzi.model.TeachingSchedule s : allSchedules) {
        if (s.getSessionDate() != null) {
            java.time.LocalDate d = s.getSessionDate().toLocalDate();
            if (!d.isBefore(startOfWeek) && d.isBefore(endOfWeek)) {
                int dayIndex = (int) java.time.temporal.ChronoUnit.DAYS.between(startOfWeek, d);
                weekSchedules.get(dayIndex).add(s);
            }
        }
    }
    String scheduleMonthYear = "Tháng " + startOfWeek.getMonthValue() + ", " + startOfWeek.getYear();
    String[] eventColors = {"event-blue", "event-purple", "event-green", "event-yellow", "event-pink"};
%>

            <div class="schedule-header">
                <h2><%= scheduleMonthYear %></h2>
                <div class="schedule-btn-group">
                    <button onclick="changeScheduleWeek(-1)">&lt;</button>
                    <button class="active">Tuần</button>
                    <button onclick="changeScheduleWeek(1)">&gt;</button>
                </div>
                <div class="schedule-actions">
                    <button class="schedule-close-btn" onclick="closeScheduleModal()" style="margin-left: 1rem;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
            </div>
            <div class="schedule-body">
                <div class="schedule-days-header">
                    <div></div>
                    <% for(int i=0; i<7; i++) { 
                        java.time.LocalDate d = startOfWeek.plusDays(i);
                        String dayName = (i == 6) ? "CN" : "Thứ " + (i + 2);
                        boolean isActive = d.equals(today);
                    %>
                    <div class="schedule-day-col <%= isActive ? "active" : "" %>">
                        <div class="schedule-day-name"><%= dayName %></div>
                        <div class="schedule-day-num"><%= d.getDayOfMonth() %></div>
                    </div>
                    <% } %>
                </div>
                <div class="schedule-grid">
                    <div class="schedule-time-col">
                        <div class="schedule-time-slot" style="margin-top: 0px;">7 am</div>
                        <div class="schedule-time-slot">8 am</div>
                        <div class="schedule-time-slot">9 am</div>
                        <div class="schedule-time-slot">10 am</div>
                        <div class="schedule-time-slot">11 am</div>
                        <div class="schedule-time-slot">12 pm</div>
                        <div class="schedule-time-slot">1 pm</div>
                        <div class="schedule-time-slot">2 pm</div>
                        <div class="schedule-time-slot">3 pm</div>
                        <div class="schedule-time-slot">4 pm</div>
                        <div class="schedule-time-slot">5 pm</div>
                        <div class="schedule-time-slot">6 pm</div>
                        <div class="schedule-time-slot">7 pm</div>
                        <div class="schedule-time-slot">8 pm</div>
                        <div class="schedule-time-slot">9 pm</div>
                        <div class="schedule-time-slot">10 pm</div>
                    </div>
                    <div class="schedule-grid-cols">
                        <% for(int i=0; i<7; i++) { 
                            java.util.List<com.hipzi.model.TeachingSchedule> daySchedules = weekSchedules.get(i);
                        %>
                        <div class="schedule-grid-col">
                            <% 
                               int colorIdx = 0;
                               for(com.hipzi.model.TeachingSchedule s : daySchedules) { 
                                  java.time.LocalTime st = s.getStartTime() != null ? s.getStartTime().toLocalTime() : java.time.LocalTime.of(7,0);
                                  java.time.LocalTime et = s.getEndTime() != null ? s.getEndTime().toLocalTime() : java.time.LocalTime.of(8,0);
                                  
                                  int topMinutes = (st.getHour() - 7) * 60 + st.getMinute();
                                  int topPx = (int) (topMinutes * 80.0 / 60.0);
                                  
                                  int durMinutes = (int) java.time.temporal.ChronoUnit.MINUTES.between(st, et);
                                  int heightPx = (int) (durMinutes * 80.0 / 60.0);
                                  
                                  String colorClass = eventColors[(colorIdx++) % eventColors.length];
                                  
                                  java.time.format.DateTimeFormatter timeFormatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm");
                            %>
                            <div class="schedule-event <%= colorClass %>" style="top: <%= topPx %>px; height: <%= heightPx %>px;" title="<%= s.getClassroomTitle() != null ? s.getClassroomTitle() : "" %>">
                                <div class="schedule-event-title"><%= s.getClassroomTitle() != null ? s.getClassroomTitle() : "Lớp học" %></div>
                                <div class="schedule-event-time"><%= st.format(timeFormatter) %> - <%= et.format(timeFormatter) %></div>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
