import com.hipzi.dao.MockExamDao;
import com.hipzi.model.MockExam;
import com.hipzi.model.MockExamQuestion;
import java.util.ArrayList;
import java.util.List;

public class TestInsert {
    public static void main(String[] args) {
        MockExamDao dao = new MockExamDao();
        MockExam exam = new MockExam();
        exam.setTitle("Test Exam Duration 45");
        exam.setExamType("multiple_choice");
        exam.setSubject("Toán");
        exam.setGradeLevel("Lớp 10");
        exam.setDurationMinutes(45);
        exam.setStatus("published");
        
        List<MockExamQuestion> qs = new ArrayList<>();
        MockExamQuestion q = new MockExamQuestion();
        q.setQuestionText("1+1=?");
        q.setOptionA("1");
        q.setOptionB("2");
        q.setOptionC("3");
        q.setOptionD("4");
        q.setCorrectOption("B");
        qs.add(q);
        
        boolean ok = dao.createMultipleChoice(exam, qs);
        System.out.println("Insert OK? " + ok);
        
        List<MockExam> list = dao.listPublishedByType("multiple_choice", 10);
        for (MockExam me : list) {
            System.out.println("Found: " + me.getTitle() + ", Duration: " + me.getDurationMinutes());
        }
    }
}