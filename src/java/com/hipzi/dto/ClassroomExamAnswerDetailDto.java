package com.hipzi.dto;

import com.hipzi.model.ClassroomExamAnswer;
import com.hipzi.model.ClassroomExamQuestion;
import java.io.Serializable;

public class ClassroomExamAnswerDetailDto implements Serializable {

    private ClassroomExamQuestion question;
    private ClassroomExamAnswer answer;

    public ClassroomExamAnswerDetailDto() {
    }

    public ClassroomExamAnswerDetailDto(ClassroomExamQuestion question, ClassroomExamAnswer answer) {
        this.question = question;
        this.answer = answer;
    }

    public ClassroomExamQuestion getQuestion() {
        return question;
    }

    public void setQuestion(ClassroomExamQuestion question) {
        this.question = question;
    }

    public ClassroomExamAnswer getAnswer() {
        return answer;
    }

    public void setAnswer(ClassroomExamAnswer answer) {
        this.answer = answer;
    }
}
