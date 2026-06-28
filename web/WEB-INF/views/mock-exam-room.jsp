<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.User"%>
<%@page import="com.hipzi.model.MockExam"%>
<%@page import="com.hipzi.model.MockExamQuestion"%>
<%@page import="java.util.List"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String js(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\r", "\\r")
                    .replace("\n", "\\n")
                    .replace("\t", "\\t")
                    .replace("<", "\\u003c")
                    .replace(">", "\\u003e")
                    .replace("&", "\\u0026");
    }
%>
<%
    if (!Boolean.TRUE.equals(request.getAttribute("mockExamRoomRequest"))) {
        response.sendRedirect(request.getContextPath() + "/mock-exams");
        return;
    }
    User user = (User) session.getAttribute("loggedUser");
    MockExam mockExam = (MockExam) request.getAttribute("mockExam");
    List<MockExamQuestion> examQuestions = (List<MockExamQuestion>) request.getAttribute("examQuestions");
    int examQuestionCount = mockExam != null ? mockExam.getItemCount() : 0;
    int examDurationMinutes = mockExam != null && mockExam.getDurationMinutes() != null ? mockExam.getDurationMinutes() : 45;
    String examTitle = mockExam != null ? mockExam.getTitle() : "";
    String examType = mockExam != null ? mockExam.getExamType() : "multiple_choice";
    
    String initials = "H";
    if (user != null && user.getDisplayName() != null && !user.getDisplayName().isEmpty()) {
        String[] parts = user.getDisplayName().trim().split("\\s+");
        initials = parts[parts.length - 1].substring(0, 1).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bài thi - HIPZI</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=5">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
    <style>
        html, body {
            height: 100%;
            margin: 0;
            overflow: hidden;
            background: #f4f8fb;
            color: #172033;
            font-family: 'Be Vietnam Pro', sans-serif;
        }

        .exam-workspace {
            display: flex;
            flex-direction: column;
            height: 100%;
        }

        .exam-workspace-header {
            display: flex;
            min-height: 72px;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            border-bottom: 1px solid #d9e4ec;
            background: #ffffff;
            padding: 0.85rem 1.4rem;
            box-shadow: 0 4px 16px rgba(15, 23, 42, 0.05);
        }

        .exam-workspace-brand {
            display: flex;
            align-items: center;
            gap: 0.7rem;
            text-decoration: none;
        }

        .exam-workspace-brand img {
            width: 42px;
            height: 42px;
            border-radius: 12px;
        }

        .exam-workspace-brand strong, .exam-workspace-title strong {
            display: block;
            color: #0f172a;
            font-size: 0.94rem;
        }

        .exam-workspace-brand span, .exam-workspace-title span {
            display: block;
            margin-top: 0.15rem;
            color: #64748b;
            font-size: 0.76rem;
            font-weight: 700;
        }

        .exam-workspace-title {
            min-width: 0;
            text-align: center;
        }

        .exam-workspace-title strong {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: 1.02rem;
        }

        .exam-workspace-meta {
            display: flex;
            justify-content: flex-end;
            gap: 0.55rem;
        }

        .exam-status-pill {
            display: flex;
            align-items: center;
            gap: 0.42rem;
            border-radius: 999px;
            padding: 0.5rem 0.72rem;
            font-size: 0.74rem;
            font-weight: 900;
            background: #ecfdf5;
            color: #047857;
        }

        .exam-workspace-body {
            display: grid;
            min-height: 0;
            flex: 1;
            grid-template-columns: 280px minmax(0, 1fr);
            gap: 1rem;
            padding: 1rem;
        }

        .exam-sidebar, .exam-question-card {
            border: 1px solid #dde7ef;
            border-radius: 18px;
            background: #ffffff;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.06);
        }

        .exam-sidebar {
            display: flex;
            min-height: 0;
            flex-direction: column;
            gap: 1rem;
            padding: 1rem;
            overflow-y: auto;
        }

        .exam-timer {
            border-radius: 16px;
            background: linear-gradient(135deg, #0f766e, #14b8a6);
            padding: 1rem;
            color: #ffffff;
        }

        .exam-timer span, .exam-sidebar-section-title {
            display: block;
            font-size: 0.74rem;
            font-weight: 900;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .exam-timer strong {
            display: block;
            margin-top: 0.32rem;
            font-size: 1.65rem;
            letter-spacing: 0.06em;
        }

        .exam-progress-track {
            height: 7px;
            overflow: hidden;
            border-radius: 999px;
            background: #e2e8f0;
        }

        .exam-progress-track span {
            display: block;
            width: 0;
            height: 100%;
            border-radius: inherit;
            background: #14b8a6;
            transition: width 0.2s ease;
        }

        .exam-question-grid {
            display: grid;
            grid-template-columns: repeat(5, minmax(0, 1fr));
            gap: 0.45rem;
        }

        .exam-question-number {
            aspect-ratio: 1;
            border: 1px solid #cbd5e1;
            border-radius: 9px;
            background: #ffffff;
            color: #475569;
            cursor: pointer;
            font-size: 0.78rem;
            font-weight: 900;
            transition: all 0.18s ease;
        }

        .exam-question-number.current {
            border-color: #0f766e;
            background: #ccfbf1;
            color: #0f766e;
        }

        .exam-question-number.answered {
            border-color: #0f766e;
            background: #0f766e;
            color: #ffffff;
        }

        .exam-question-number.current.answered {
            box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.2);
        }

        .exam-sidebar-note {
            margin-top: auto;
            border-radius: 14px;
            background: #f0fdfa;
            padding: 0.8rem;
            color: #0f766e;
            font-size: 0.74rem;
            font-weight: 700;
            line-height: 1.55;
        }

        .exam-question-card {
            display: flex;
            min-height: 0;
            flex-direction: column;
            padding: 1.35rem;
            overflow-y: auto;
        }

        .exam-question-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 1rem;
        }

        .exam-question-head span {
            color: #0f766e;
            font-size: 0.8rem;
            font-weight: 900;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        .exam-question-head strong {
            color: #64748b;
            font-size: 0.8rem;
        }

        .exam-question-content {
            padding: 1.45rem 0;
        }

        .exam-question-content h2 {
            margin: 0;
            color: #0f172a;
            font-size: clamp(1.1rem, 2vw, 1.35rem);
            line-height: 1.6;
        }

        .exam-option-list {
            display: grid;
            gap: 0.75rem;
            margin-top: 1.4rem;
        }

        .exam-option {
            display: flex;
            align-items: center;
            gap: 0.9rem;
            border: 1px solid #dbe5ed;
            border-radius: 14px;
            background: #ffffff;
            padding: 0.9rem 1rem;
            color: #334155;
            cursor: pointer;
            font-size: 0.92rem;
            font-weight: 700;
            text-align: left;
            transition: all 0.18s ease;
        }

        .exam-option:hover {
            border-color: #5eead4;
            background: #f0fdfa;
            transform: translateY(-1px);
        }

        .exam-option.selected {
            border-color: #0f766e;
            background: #ccfbf1;
            color: #115e59;
        }

        .exam-option-key {
            display: inline-flex;
            width: 32px;
            height: 32px;
            flex: 0 0 auto;
            align-items: center;
            justify-content: center;
            border-radius: 9px;
            background: #f1f5f9;
            color: #475569;
            font-size: 0.82rem;
            font-weight: 900;
        }

        .exam-option.selected .exam-option-key {
            background: #0f766e;
            color: #ffffff;
        }

        .exam-essay-answer {
            box-sizing: border-box;
            width: 100%;
            min-height: 220px;
            resize: vertical;
            border: 1px solid #dbe5ed;
            border-radius: 14px;
            background: #ffffff;
            padding: 1rem;
            color: #334155;
            font: inherit;
            line-height: 1.6;
        }

        .exam-question-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            margin-top: auto;
            border-top: 1px solid #e2e8f0;
            padding-top: 1rem;
        }

        .exam-nav-btn, .exam-submit-btn, .exam-confirm-btn, .exam-cancel-btn {
            border: 0;
            border-radius: 999px;
            cursor: pointer;
            padding: 0.78rem 1rem;
            font-size: 0.82rem;
            font-weight: 900;
        }

        .exam-nav-btn {
            background: #eef2f7;
            color: #334155;
        }

        .exam-submit-btn, .exam-confirm-btn {
            background: #0f766e;
            color: #ffffff;
        }

        .exam-submit-btn {
            margin-left: auto;
        }

        .exam-submit-overlay {
            position: absolute;
            inset: 0;
            z-index: 4;
            display: none;
            align-items: center;
            justify-content: center;
            background: rgba(15, 23, 42, 0.58);
            padding: 1rem;
            backdrop-filter: blur(5px);
        }

        .exam-submit-overlay.active {
            display: flex;
        }

        .exam-submit-card {
            width: min(440px, 100%);
            border: 1px solid rgba(148, 163, 184, 0.28);
            border-radius: 20px;
            background: #ffffff;
            padding: 1.45rem;
            text-align: center;
            box-shadow: 0 28px 72px rgba(15, 23, 42, 0.3);
        }

        .exam-submit-icon {
            display: inline-flex;
            width: 52px;
            height: 52px;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: #ccfbf1;
            color: #0f766e;
            font-size: 1.35rem;
            font-weight: 900;
        }

        .exam-submit-card h2 {
            margin: 0.85rem 0 0;
            color: #0f172a;
            font-size: 1.22rem;
        }

        .exam-submit-card p {
            margin: 0.65rem 0 0;
            color: #64748b;
            font-size: 0.86rem;
            line-height: 1.6;
        }

        .exam-submit-summary {
            margin-top: 0.9rem;
            border-radius: 14px;
            background: #f8fafc;
            padding: 0.78rem;
            color: #334155;
            font-size: 0.82rem;
            font-weight: 800;
        }

        .exam-submit-actions {
            display: flex;
            justify-content: center;
            gap: 0.65rem;
            margin-top: 1rem;
        }

        .exam-cancel-btn {
            background: #eef2f7;
            color: #475569;
        }

        @media (max-width: 980px) {
            .exam-workspace-body {
                grid-template-columns: 220px minmax(0, 1fr);
            }
        }
        @media (max-width: 680px) {
            .exam-workspace-body {
                grid-template-columns: 1fr;
                overflow-y: auto;
            }
            .exam-sidebar, .exam-question-card {
                min-height: auto;
            }
            html, body {
                overflow: auto;
            }
        }
    </style>
</head>
<body>

    <section class="exam-workspace" id="examWorkspace">
        <header class="exam-workspace-header">
            <a href="${pageContext.request.contextPath}/mock-exams" class="exam-workspace-brand" title="Quay lại danh sách đề">
                <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="">
                <div>
                    <strong>HIPZI Mock Exam</strong>
                    <span>Phòng thi công khai</span>
                </div>
            </a>
            <div class="exam-workspace-title">
                <strong><%= h(examTitle) %></strong>
                <span><%= examQuestionCount %> câu hỏi · Cho phép chuyển tab</span>
            </div>
            <div class="exam-workspace-meta">
                <span class="exam-status-pill">Đang làm bài</span>
            </div>
        </header>

        <div class="exam-workspace-body">
            <aside class="exam-sidebar">
                <div class="exam-timer">
                    <span>Thời gian còn lại</span>
                    <strong id="examTimer">--:--</strong>
                </div>
                <div>
                    <span class="exam-sidebar-section-title">Tiến độ làm bài</span>
                    <div class="exam-progress-track" style="margin-top: 0.55rem;"><span id="examProgressBar"></span></div>
                    <span id="examProgressText" style="display:block; margin-top:0.45rem; color:#64748b; font-size:0.75rem; font-weight:800;">Đã trả lời 0/<%= examQuestionCount %> câu</span>
                </div>
                <div>
                    <span class="exam-sidebar-section-title">Danh sách câu hỏi</span>
                    <div class="exam-question-grid" id="examQuestionGrid" style="margin-top: 0.65rem;"></div>
                </div>
                <div class="exam-sidebar-note">
                    Đây là bài thi công khai. Bạn có thể thoát, đổi tab, và tiếp tục bài thi một cách thoải mái.
                </div>
            </aside>

            <section class="exam-question-card">
                <div class="exam-question-head">
                    <span id="examQuestionLabel">Câu hỏi 1</span>
                    <strong id="examQuestionMode"><%= "essay".equals(examType) ? "Nhập câu trả lời" : "Chọn một đáp án đúng" %></strong>
                </div>
                <div class="exam-question-content">
                    <h2 id="examQuestionText"></h2>
                    <div class="exam-option-list" id="examOptionList"></div>
                </div>
                <footer class="exam-question-footer">
                    <button class="exam-nav-btn" id="examPrevBtn" type="button">Câu trước</button>
                    <button class="exam-nav-btn" id="examNextBtn" type="button">Câu tiếp theo</button>
                    <button class="exam-submit-btn" id="examSubmitBtn" type="button">Nộp bài</button>
                </footer>
            </section>
        </div>

        <div class="exam-submit-overlay" id="examSubmitOverlay">
            <div class="exam-submit-card">
                <div class="exam-submit-icon" aria-hidden="true">✓</div>
                <h2 id="examSubmitTitle">Xác nhận nộp bài?</h2>
                <p>Sau khi xác nhận, bài làm sẽ kết thúc và bạn sẽ được xem kết quả ngay.</p>
                <div class="exam-submit-summary" id="examSubmitSummary">Bạn đã trả lời 0/<%= examQuestionCount %> câu.</div>
                <div class="exam-submit-actions">
                    <button class="exam-cancel-btn" id="examCancelSubmitBtn" type="button">Tiếp tục làm bài</button>
                    <button class="exam-confirm-btn" id="examConfirmSubmitBtn" type="button">Xác nhận nộp bài</button>
                </div>
            </div>
        </div>

        <div class="exam-submit-overlay" id="examResultOverlay">
            <div class="exam-submit-card">
                <div class="exam-submit-icon" aria-hidden="true" style="background:#dcfce7; color:#166534;">🎉</div>
                <h2>Kết quả bài thi</h2>
                <p>Bài làm của bạn đã được nộp thành công.</p>
                <div class="exam-submit-summary" style="display:flex; justify-content:space-around; background:transparent; padding:0; gap:10px;">
                    <div style="background:#f0fdf4; border:1px solid #bbf7d0; color:#166534; padding:1rem; border-radius:12px; flex:1;">
                        <strong style="font-size:1.6rem; display:block;" id="resultCorrectCount">0</strong>
                        <span style="font-size:0.8rem;">Câu đúng</span>
                    </div>
                    <div style="background:#fef2f2; border:1px solid #fecaca; color:#991b1b; padding:1rem; border-radius:12px; flex:1;">
                        <strong style="font-size:1.6rem; display:block;" id="resultIncorrectCount">0</strong>
                        <span style="font-size:0.8rem;">Câu sai</span>
                    </div>
                </div>
                <div class="exam-submit-actions">
                    <a href="${pageContext.request.contextPath}/mock-exams" class="exam-confirm-btn" style="text-decoration:none; display:inline-block; width:100%; box-sizing:border-box;">Trở về danh sách đề thi</a>
                </div>
            </div>
        </div>
    </section>

    <script>
    (function () {
        var timer = document.getElementById('examTimer');
        var progressBar = document.getElementById('examProgressBar');
        var progressText = document.getElementById('examProgressText');
        var questionGrid = document.getElementById('examQuestionGrid');
        var questionLabel = document.getElementById('examQuestionLabel');
        var questionMode = document.getElementById('examQuestionMode');
        var questionText = document.getElementById('examQuestionText');
        var optionList = document.getElementById('examOptionList');
        var prevBtn = document.getElementById('examPrevBtn');
        var nextBtn = document.getElementById('examNextBtn');
        var examSubmitBtn = document.getElementById('examSubmitBtn');
        var submitOverlay = document.getElementById('examSubmitOverlay');
        var submitSummary = document.getElementById('examSubmitSummary');
        var cancelSubmitBtn = document.getElementById('examCancelSubmitBtn');
        var confirmSubmitBtn = document.getElementById('examConfirmSubmitBtn');

        var examQuestions = [
        <% if (examQuestions != null) {
            for (int i = 0; i < examQuestions.size(); i++) {
                MockExamQuestion question = examQuestions.get(i);
        %>
            {
                id: "<%= js(question.getId()) %>",
                type: "multiple_choice",
                text: "<%= js(question.getQuestionText()) %>",
                options: ["<%= js(question.getOptionA()) %>", "<%= js(question.getOptionB()) %>", "<%= js(question.getOptionC()) %>", "<%= js(question.getOptionD()) %>"]
            }<%= i + 1 < examQuestions.size() ? "," : "" %>
        <%  }
        } %>
        ];

        var examType = "<%= js(examType) %>";
        var examDurationMinutes = <%= examDurationMinutes %>;
        var answers = {};
        var currentQuestion = 0;
        var secondsLeft = examDurationMinutes * 60;
        var timerInterval = null;

        function formatTime(value) {
            var minutes = Math.floor(value / 60);
            var seconds = value % 60;
            return String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
        }

        function renderTimer() {
            timer.textContent = formatTime(secondsLeft);
        }

        function answeredCount() {
            return Object.keys(answers).length;
        }

        function renderProgress() {
            var completed = answeredCount();
            progressBar.style.width = Math.round((completed / examQuestions.length) * 100) + '%';
            progressText.textContent = 'Đã trả lời ' + completed + '/' + examQuestions.length + ' câu';
        }

        function renderQuestionGrid() {
            questionGrid.innerHTML = '';
            examQuestions.forEach(function (_, index) {
                var button = document.createElement('button');
                button.type = 'button';
                button.className = 'exam-question-number';
                if (index === currentQuestion) button.classList.add('current');
                if (answers[index]) button.classList.add('answered');
                button.textContent = index + 1;
                button.addEventListener('click', function () {
                    currentQuestion = index;
                    renderQuestion();
                });
                questionGrid.appendChild(button);
            });
        }

        function renderQuestion() {
            if (!examQuestions.length) return;
            var question = examQuestions[currentQuestion];
            questionLabel.textContent = 'Câu hỏi ' + (currentQuestion + 1);
            questionText.textContent = question.text;
            optionList.innerHTML = '';
            if (examType === 'essay') {
                questionMode.textContent = 'Nhập câu trả lời';
                var textarea = document.createElement('textarea');
                textarea.className = 'exam-essay-answer';
                textarea.placeholder = 'Nhập câu trả lời của bạn tại đây...';
                textarea.value = answers[currentQuestion] || '';
                textarea.addEventListener('input', function () {
                    var value = textarea.value.trim();
                    if (value) {
                        answers[currentQuestion] = textarea.value;
                    } else {
                        delete answers[currentQuestion];
                    }
                    renderQuestionGrid();
                    renderProgress();
                });
                optionList.appendChild(textarea);
            } else {
                questionMode.textContent = 'Chọn một đáp án đúng';
                question.options.forEach(function (option, index) {
                    if (!option) return;
                    var key = String.fromCharCode(65 + index);
                    var button = document.createElement('button');
                    button.type = 'button';
                    button.className = 'exam-option';
                    if (answers[currentQuestion] === key) button.classList.add('selected');
                    button.innerHTML = '<span class="exam-option-key">' + key + '</span><span></span>';
                    button.lastChild.textContent = option;
                    button.addEventListener('click', function () {
                        answers[currentQuestion] = key;
                        renderQuestion();
                        renderQuestionGrid();
                        renderProgress();
                    });
                    optionList.appendChild(button);
                });
            }
            prevBtn.disabled = currentQuestion === 0;
            nextBtn.disabled = currentQuestion === examQuestions.length - 1;
            renderQuestionGrid();
            renderProgress();
        }

        function showSubmitConfirmation() {
            submitSummary.textContent = 'Bạn đã trả lời ' + answeredCount() + '/' + examQuestions.length + ' câu.';
            submitOverlay.classList.add('active');
        }

        function hideSubmitConfirmation() {
            submitOverlay.classList.remove('active');
        }

        function finishExam() {
            clearInterval(timerInterval);
            examSubmitBtn.disabled = true;
            examSubmitBtn.textContent = 'Đang nộp...';

            var payload = {
                examId: "<%= mockExam != null ? mockExam.getId() : "" %>",
                answers: (function() {
                    var uuidAnswers = {};
                    Object.keys(answers).forEach(function(indexStr) {
                        var idx = parseInt(indexStr, 10);
                        if (examQuestions[idx]) {
                            uuidAnswers[examQuestions[idx].id] = answers[indexStr];
                        }
                    });
                    return uuidAnswers;
                })()
            };

            fetch('${pageContext.request.contextPath}/api/mock-exam/submit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            })
            .then(function(res) {
                return res.json();
            })
            .then(function(data) {
                if (data.success) {
                    hideSubmitConfirmation();
                    var correct = data.score;
                    var incorrect = data.total - data.score;
                    document.getElementById('resultCorrectCount').textContent = correct;
                    document.getElementById('resultIncorrectCount').textContent = incorrect;
                    document.getElementById('examResultOverlay').classList.add('active');
                } else {
                    alert('Lỗi: ' + data.message);
                    examSubmitBtn.disabled = false;
                    examSubmitBtn.textContent = 'Nộp bài';
                }
            })
            .catch(function(err) {
                alert('Lỗi mạng: Không thể nộp bài.');
                examSubmitBtn.disabled = false;
                examSubmitBtn.textContent = 'Nộp bài';
            });
        }

        // Start exam
        renderTimer();
        renderQuestion();
        
        timerInterval = setInterval(function () {
            secondsLeft -= 1;
            renderTimer();
            if (secondsLeft <= 0) {
                finishExam();
            }
        }, 1000);

        prevBtn.addEventListener('click', function () {
            if (currentQuestion > 0) {
                currentQuestion -= 1;
                renderQuestion();
            }
        });

        nextBtn.addEventListener('click', function () {
            if (currentQuestion < examQuestions.length - 1) {
                currentQuestion += 1;
                renderQuestion();
            }
        });

        examSubmitBtn.addEventListener('click', function () {
            showSubmitConfirmation();
        });

        cancelSubmitBtn.addEventListener('click', function () {
            hideSubmitConfirmation();
        });

        confirmSubmitBtn.addEventListener('click', function () {
            finishExam();
        });

    })();
    </script>
</body>
</html>
