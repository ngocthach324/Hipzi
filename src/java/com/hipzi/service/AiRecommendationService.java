package com.hipzi.service;

import com.hipzi.dao.ClassroomDao;
import com.hipzi.dao.CourseDao;
import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.model.Classroom;
import com.hipzi.model.Course;
import com.hipzi.model.Material;

import java.text.Normalizer;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class AiRecommendationService {
    private final ClassroomDao classroomDao = new ClassroomDao();
    private final CourseDao courseDao = new CourseDao();
    private final RepositoryMaterialDao materialDao = new RepositoryMaterialDao();

    public AiContext buildContext(String message, String contextPath) {
        QueryHint hint = parseHint(message);
        String keyword = hint.keyword.isEmpty() ? message : hint.keyword;

        List<Classroom> classrooms = classroomDao.listPublic(hint.classroomSubject, hint.grade, keyword, "Tất cả", null);
        if ((classrooms == null || classrooms.isEmpty()) && !hint.classroomSubject.isEmpty()) {
            classrooms = classroomDao.listPublic(hint.classroomSubject, hint.grade, "", "Tất cả", null);
        }
        if ((classrooms == null || classrooms.isEmpty()) && !hint.grade.isEmpty()) {
            classrooms = classroomDao.listPublic("", hint.grade, keyword, "Tất cả", null);
        }
        if (classrooms == null) {
            classrooms = new ArrayList<>();
        }
        if (classrooms.isEmpty() && (!hint.classroomSubject.isEmpty() || !hint.grade.isEmpty())) {
            classrooms = filterClassrooms(classroomDao.listPublic("", "", "", "Tất cả", null), hint);
        } else if (classrooms.isEmpty() && hint.wantsClassroomListing) {
            classrooms = classroomDao.listPublic("", "", "", "Tất cả", null);
            if (classrooms == null) {
                classrooms = new ArrayList<>();
            }
        }
        if (!classrooms.isEmpty() && (!hint.classroomSubject.isEmpty() || !hint.grade.isEmpty())) {
            classrooms = filterClassrooms(classrooms, hint);
        }

        // Use AI-specific search: match by subject_name (ILIKE) which is flexible,
        // does NOT use the full user message as keyword (which would never match course titles).
        List<Course> courses = courseDao.searchForAi(hint.classroomSubject, hint.courseSubjectCode, 5);
        if (courses.isEmpty() && !hint.materialSubject.isEmpty()) {
            courses = courseDao.searchForAi(hint.materialSubject, hint.courseSubjectCode, 5);
        }
        if (courses.isEmpty()) {
            // No subject detected – return top featured public courses
            courses = courseDao.searchForAi(null, null, 5);
        }


        List<Material> materials = materialDao.search("ALL", "ALL", "ALL", keyword, "newest", 1, 5);
        if (materials.isEmpty() && !hint.materialSubject.isEmpty()) {
            materials = materialDao.search(hint.materialSubject, "ALL", "ALL", "", "newest", 1, 5);
        }

        return new AiContext(limitClassrooms(classrooms, 4), limitCourses(courses, 4), limitMaterials(materials, 4), hint, contextPath);
    }

    private QueryHint parseHint(String message) {
        String normalized = normalize(message);
        QueryHint hint = new QueryHint();
        hint.keyword = message == null ? "" : message.trim();

        if (normalized.contains("toan")) {
            hint.classroomSubject = "To\u00e1n";
            hint.courseSubjectCode = "math";
            hint.materialSubject = "To\u00e1n";
        } else if (normalized.contains("tieng anh") || normalized.contains("anh van") || normalized.contains("english")
                || normalized.contains("mon anh") || normalized.contains("lop anh") || normalized.contains(" anh ")) {
            hint.classroomSubject = "Anh";
            hint.courseSubjectCode = "english";
            hint.materialSubject = "Ti\u1ebfng Anh";
        } else if (normalized.contains("ngu van") || normalized.contains("van hoc")
                || normalized.contains("mon van") || normalized.contains("lop van") || normalized.contains(" van ")) {
            hint.classroomSubject = "V\u0103n";
            hint.courseSubjectCode = "literature";
            hint.materialSubject = "V\u0103n";
        } else if (normalized.contains("vat ly") || normalized.contains("mon ly")
                || normalized.contains("lop ly") || normalized.contains(" ly ")) {
            hint.classroomSubject = "L\u00fd";
            hint.courseSubjectCode = "physics";
            hint.materialSubject = "L\u00fd";
        } else if (normalized.contains("hoa hoc") || normalized.contains("mon hoa")
                || normalized.contains("lop hoa") || normalized.contains(" hoa ")) {
            hint.classroomSubject = "H\u00f3a";
            hint.courseSubjectCode = "chemistry";
            hint.materialSubject = "H\u00f3a";
        } else if (normalized.contains("sinh hoc") || normalized.contains("mon sinh")
                || normalized.contains("lop sinh") || normalized.contains(" sinh ")) {
            hint.classroomSubject = "Sinh H\u1ecdc";
            hint.courseSubjectCode = "biology";
            hint.materialSubject = "Sinh H\u1ecdc";
        } else if (normalized.contains("lap trinh") || normalized.contains("tin hoc") || normalized.contains("python")
                || normalized.contains("java") || normalized.contains("c++") || normalized.contains("javascript")) {
            hint.classroomSubject = "Tin H\u1ecdc";
            hint.courseSubjectCode = "it";
            hint.materialSubject = "Tin h\u1ecdc";
        }

        for (int grade = 1; grade <= 12; grade++) {
            if (normalized.contains("lop " + grade) || normalized.contains("lop" + grade)) {
                hint.grade = "L\u1edbp " + grade;
                break;
            }
        }

        hint.wantsClassroomListing = normalized.contains("lop hoc dang co")
                || normalized.contains("nhung lop hoc nao")
                || normalized.contains("co nhung lop")
                || normalized.contains("danh sach lop")
                || normalized.contains("cac lop hoc");
        return hint;
    }

    private List<Course> limitCourses(List<Course> input, int limit) {
        List<Course> out = new ArrayList<>();
        if (input == null) return out;
        for (Course course : input) {
            if (course == null) continue;
            out.add(course);
            if (out.size() >= limit) break;
        }
        return out;
    }

    private List<Classroom> limitClassrooms(List<Classroom> input, int limit) {
        List<Classroom> out = new ArrayList<>();
        if (input == null) return out;
        for (Classroom classroom : input) {
            if (classroom == null) continue;
            out.add(classroom);
            if (out.size() >= limit) break;
        }
        return out;
    }

    private List<Classroom> filterClassrooms(List<Classroom> input, QueryHint hint) {
        List<Classroom> out = new ArrayList<>();
        if (input == null) return out;
        String subject = normalize(hint.classroomSubject);
        String grade = normalize(hint.grade);
        for (Classroom classroom : input) {
            if (classroom == null) continue;
            String subjectHaystack = normalize(nullToEmpty(classroom.getSubject()) + " " + nullToEmpty(classroom.getTitle()));
            String gradeHaystack = normalize(nullToEmpty(classroom.getTitle()) + " "
                    + nullToEmpty(classroom.getGrade()) + " " + nullToEmpty(classroom.getDescription()));
            if (!subject.isEmpty() && !matchesSubject(subjectHaystack, subject)) {
                continue;
            }
            if (!grade.isEmpty() && !gradeHaystack.contains(grade)) {
                continue;
            }
            out.add(classroom);
        }
        return out;
    }

    private List<Material> limitMaterials(List<Material> input, int limit) {
        List<Material> out = new ArrayList<>();
        if (input == null) return out;
        for (Material material : input) {
            if (material == null) continue;
            out.add(material);
            if (out.size() >= limit) break;
        }
        return out;
    }

    private String normalize(String value) {
        if (value == null) return "";
        String normalized = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('\u0111', 'd')
                .replace('\u0110', 'D')
                .toLowerCase(Locale.ROOT);
        return normalized.replaceAll("[^a-z0-9\\s]", " ").replaceAll("\\s+", " ").trim();
    }

    private boolean matchesSubject(String haystack, String subject) {
        if (haystack == null || subject == null || subject.isEmpty()) return true;
        if (subject.length() <= 3) {
            return (" " + haystack + " ").contains(" " + subject + " ");
        }
        return haystack.contains(subject);
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }

    public static class AiContext {
        private final List<Classroom> classrooms;
        private final List<Course> courses;
        private final List<Material> materials;
        private final QueryHint hint;
        private final String contextPath;

        AiContext(List<Classroom> classrooms, List<Course> courses, List<Material> materials, QueryHint hint, String contextPath) {
            this.classrooms = classrooms;
            this.courses = courses;
            this.materials = materials;
            this.hint = hint;
            this.contextPath = contextPath == null ? "" : contextPath;
        }

        public List<Classroom> getClassrooms() { return classrooms; }
        public List<Course> getCourses() { return courses; }
        public List<Material> getMaterials() { return materials; }
        public QueryHint getHint() { return hint; }
        public String getContextPath() { return contextPath; }
        public boolean hasData() { return !classrooms.isEmpty() || !courses.isEmpty() || !materials.isEmpty(); }
    }

    public static class QueryHint {
        private String classroomSubject = "";
        private String courseSubjectCode;
        private String materialSubject = "";
        private String grade = "";
        private String keyword = "";
        private boolean wantsClassroomListing;

        public String getClassroomSubject() { return classroomSubject; }
        public String getCourseSubjectCode() { return courseSubjectCode; }
        public String getMaterialSubject() { return materialSubject; }
        public String getGrade() { return grade; }
        public String getKeyword() { return keyword; }
        public boolean isWantsClassroomListing() { return wantsClassroomListing; }
    }
}
