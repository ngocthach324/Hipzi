import java.math.BigDecimal;
import com.hipzi.model.Course;
import com.hipzi.dao.CourseDao;

public class TestInsert {
    public static void main(String[] args) {
        Course course = new Course();
        course.setTeacherId("00000000-0000-0000-0000-000000000000");
        course.setTitle("Test Free Course");
        course.setShortDescription("desc");
        course.setSubjectCode("math");
        course.setSubjectName("Math");
        course.setPriceAmount(BigDecimal.ZERO);
        course.setPriceType("free");
        course.setLessonsCount(4);
        course.setEstimatedHours(new BigDecimal("10"));
        course.setGoogleDriveUrl("https://drive.google.com/test");
        course.setDriveOwnerEmail("test@test.com");
        course.setLearningObjectives("obj");
        course.setCurriculumOutline("outline");
        
        CourseDao dao = new CourseDao();
        boolean res = dao.createForTeacher(course);
        System.out.println("Result: " + res);
    }
}
