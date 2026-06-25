package com.hipzi.service;

import com.hipzi.dao.TeachingScheduleDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.TeachingSchedule;

import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ClassSessionService {

    private final TeachingScheduleDao scheduleDao;

    public ClassSessionService() {
        this.scheduleDao = new TeachingScheduleDao();
    }

    public void generateSchedulesForClassroom(Classroom classroom) {
        if (classroom.getScheduleDays() == null || classroom.getStartTime() == null || classroom.getEndTime() == null) {
            return;
        }

        List<DayOfWeek> daysOfWeek = parseScheduleDays(classroom.getScheduleDays());
        if (daysOfWeek.isEmpty()) {
            return;
        }

        List<TeachingSchedule> schedules = new ArrayList<>();
        LocalDate currentDate = LocalDate.now();
        // Generate for 12 weeks
        LocalDate endDate = currentDate.plusWeeks(12);

        while (currentDate.isBefore(endDate) || currentDate.isEqual(endDate)) {
            if (daysOfWeek.contains(currentDate.getDayOfWeek())) {
                TeachingSchedule s = new TeachingSchedule();
                s.setClassroomId(classroom.getId());
                s.setTeacherId(classroom.getTeacherId());
                s.setTitle(classroom.getTitle());
                s.setSessionDate(Date.valueOf(currentDate));
                s.setStartTime(classroom.getStartTime());
                s.setEndTime(classroom.getEndTime());
                s.setSource("auto");
                s.setSessionType("online"); // default
                s.setStatus("scheduled");
                s.setDescription("Buổi học tự động sinh từ lịch lớp");
                schedules.add(s);
            }
            currentDate = currentDate.plusDays(1);
        }

        if (!schedules.isEmpty()) {
            scheduleDao.createBatch(schedules);
        }
    }

    public void regenerateOnScheduleChange(Classroom oldClassroom, Classroom newClassroom) {
        boolean scheduleChanged = false;

        String oldDays = oldClassroom.getScheduleDays() != null ? oldClassroom.getScheduleDays() : "";
        String newDays = newClassroom.getScheduleDays() != null ? newClassroom.getScheduleDays() : "";
        
        String oldStart = oldClassroom.getStartTime() != null ? oldClassroom.getStartTime().toString() : "";
        String newStart = newClassroom.getStartTime() != null ? newClassroom.getStartTime().toString() : "";
        
        String oldEnd = oldClassroom.getEndTime() != null ? oldClassroom.getEndTime().toString() : "";
        String newEnd = newClassroom.getEndTime() != null ? newClassroom.getEndTime().toString() : "";

        if (!oldDays.equals(newDays) || !oldStart.equals(newStart) || !oldEnd.equals(newEnd)) {
            scheduleChanged = true;
        }

        if (scheduleChanged) {
            // Xóa các buổi học auto trong tương lai
            scheduleDao.deleteAutoFuture(newClassroom.getId());
            // Sinh lại
            generateSchedulesForClassroom(newClassroom);
        }
    }

    private List<DayOfWeek> parseScheduleDays(String scheduleDays) {
        List<DayOfWeek> days = new ArrayList<>();
        if (scheduleDays == null || scheduleDays.isEmpty()) return days;

        String lowerDays = scheduleDays.toLowerCase();
        if (lowerDays.contains("thứ 2") || lowerDays.contains("thứ hai")) days.add(DayOfWeek.MONDAY);
        if (lowerDays.contains("thứ 3") || lowerDays.contains("thứ ba")) days.add(DayOfWeek.TUESDAY);
        if (lowerDays.contains("thứ 4") || lowerDays.contains("thứ tư")) days.add(DayOfWeek.WEDNESDAY);
        if (lowerDays.contains("thứ 5") || lowerDays.contains("thứ năm")) days.add(DayOfWeek.THURSDAY);
        if (lowerDays.contains("thứ 6") || lowerDays.contains("thứ sáu")) days.add(DayOfWeek.FRIDAY);
        if (lowerDays.contains("thứ 7") || lowerDays.contains("thứ bảy")) days.add(DayOfWeek.SATURDAY);
        if (lowerDays.contains("chủ nhật") || lowerDays.contains("cn")) days.add(DayOfWeek.SUNDAY);

        return days;
    }
}
