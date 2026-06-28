<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.hipzi.model.MockExam"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.List"%>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }

    private String mockExamTypeLabel(String type) {
        return "essay".equals(type) ? "Tự luận" : "Trắc nghiệm";
    }

    private String mockExamStatusLabel(String status) {
        if ("published".equals(status)) return "Đã xuất bản";
        if ("archived".equals(status)) return "Đã lưu trữ";
        return "Bản nháp";
    }
%>
<%
    String tabParam = request.getParameter("tab");
    boolean activeMockExamTab = "mock-exams".equals(tabParam) || "tab-mock-exams".equals(tabParam);
    List<MockExam> staffMockExams = (List<MockExam>) request.getAttribute("staffMockExams");
    String currentDateDisplay = new SimpleDateFormat("dd/MM/yyyy").format(new Date());
%>
<style>
    #tab-mock-exams input,
    #tab-mock-exams textarea,
    #tab-mock-exams select {
        width: 100%;
        border: 1px solid #dbe7ef;
        border-radius: 0.85rem;
        background: #ffffff;
        color: #0f172a;
        font-family: inherit;
        font-size: 0.95rem;
        font-weight: 650;
        line-height: 1.45;
        padding: 0.9rem 1rem;
        outline: none;
        box-shadow: 0 1px 2px rgba(15, 23, 42, 0.03);
        transition: border-color 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
    }

    #tab-mock-exams textarea {
        min-height: 96px;
        resize: vertical;
    }

    #tab-mock-exams input::placeholder,
    #tab-mock-exams textarea::placeholder {
        color: #64748b;
        font-weight: 600;
    }

    #tab-mock-exams input:focus,
    #tab-mock-exams textarea:focus,
    #tab-mock-exams select:focus {
        border-color: #10b981;
        background: #fbfffd;
        box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.12);
    }

    #tab-mock-exams select {
        appearance: none;
        background-image: linear-gradient(45deg, transparent 50%, #059669 50%), linear-gradient(135deg, #059669 50%, transparent 50%);
        background-position: calc(100% - 22px) 50%, calc(100% - 16px) 50%;
        background-size: 6px 6px, 6px 6px;
        background-repeat: no-repeat;
        padding-right: 2.75rem;
    }

    #tab-mock-exams .mock-question-block,
    #tab-mock-exams .mock-essay-block {
        background: #fbfdff;
        border: 1px solid #dbe7ef;
        border-radius: 1rem;
        padding: 1rem;
        display: grid;
        gap: 0.9rem;
    }

    #tab-mock-exams .mock-answer-grid {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 0.85rem;
    }

    #tab-mock-exams .mock-correct-row {
        display: grid;
        grid-template-columns: 180px minmax(0, 1fr) auto;
        gap: 0.85rem;
        align-items: center;
    }

    @media (max-width: 820px) {
        #tab-mock-exams .mock-answer-grid,
        #tab-mock-exams .mock-correct-row {
            grid-template-columns: 1fr;
        }
    }
</style>
<section id="tab-mock-exams" class="tab-pane <%= activeMockExamTab ? "active-pane" : "" %>">
    <div class="tab-grouped-container">
        <div class="tab-header-accent">
            <div class="tab-header-title-text">Đăng tải thi thử</div>
            <div class="tab-header-date-pill">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                <span><%= currentDateDisplay %></span>
            </div>
        </div>

        <div class="tab-body-content" style="display:grid; gap:1.25rem;">
            <div class="section-data-card">
                <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                    <div class="card-header-title">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M9 11l3 3L22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
                        <span>Tạo đề thi thử bằng dữ liệu thật</span>
                    </div>
                    <span style="font-size:0.78rem; font-weight:850; color:#047857; background:#dcfce7; padding:0.25rem 0.75rem; border-radius:999px;">mock_exams</span>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/staff-profile" style="display:grid; gap:1rem; padding-top:1.25rem;">
                    <input type="hidden" name="action" value="createMockExam">
                    <div style="display:grid; grid-template-columns:repeat(2, minmax(0, 1fr)); gap:1rem;">
                        <div class="form-group-premium">
                            <label>Loại đề</label>
                            <select id="mockExamTypeSelect" name="mockExamType" onchange="toggleMockExamTypeFields()" style="width:100%; padding:0.9rem 1rem; border:1px solid #dbe7ef; border-radius:0.85rem; font-weight:750;">
                                <option value="multiple_choice">Trắc nghiệm</option>
                                <option value="essay">Tự luận</option>
                            </select>
                        </div>
                        <div class="form-group-premium">
                            <label>Trạng thái</label>
                            <select name="mockExamStatus" style="width:100%; padding:0.9rem 1rem; border:1px solid #dbe7ef; border-radius:0.85rem; font-weight:750;">
                                <option value="published">Xuất bản lên phòng thi</option>
                                <option value="draft">Lưu bản nháp</option>
                            </select>
                        </div>
                        <div class="form-group-premium">
                            <label>Tiêu đề đề thi</label>
                            <input type="text" name="mockExamTitle" required placeholder="Kiểm tra 15 phút - Tiếng Anh lớp 10">
                        </div>
                        <div class="form-group-premium">
                            <label>Môn học</label>
                            <input type="text" name="mockExamSubject" required placeholder="Tiếng Anh, Toán, Ngữ văn...">
                        </div>
                        <div class="form-group-premium">
                            <label>Khối / cấp độ</label>
                            <input type="text" name="mockExamGrade" required placeholder="Lớp 10, THPT, Nâng cao...">
                        </div>
                        <div class="form-group-premium">
                            <label>Thời lượng phút</label>
                            <input type="number" name="mockExamDuration" min="1" placeholder="45">
                        </div>
                    </div>
                    <div class="form-group-premium">
                        <label>Mô tả ngắn</label>
                        <textarea name="mockExamDescription" rows="3" placeholder="Mục tiêu luyện tập, phạm vi kiến thức, ghi chú cho học sinh..."></textarea>
                    </div>

                    <div id="mockMcqFields" style="display:grid; gap:1rem;">
                        <div style="display:flex; justify-content:space-between; gap:1rem; align-items:center;">
                            <div>
                                <h3 style="margin:0; font-size:1rem; color:#0f172a;">Câu hỏi trắc nghiệm</h3>
                                <p style="margin:0.25rem 0 0; color:#64748b; font-weight:650;">Mỗi câu lưu 4 đáp án và một đáp án chính xác.</p>
                            </div>
                            <button type="button" class="btn-premium btn-secondary" onclick="addMockQuestionBlock()">Thêm câu hỏi</button>
                        </div>
                        <div id="mockQuestionList" style="display:grid; gap:1rem;">
                            <div class="mock-question-block">
                                <textarea name="questionText" rows="2" placeholder="Nhập nội dung câu hỏi"></textarea>
                                <div class="mock-answer-grid">
                                    <input name="optionA" type="text" placeholder="Đáp án A">
                                    <input name="optionB" type="text" placeholder="Đáp án B">
                                    <input name="optionC" type="text" placeholder="Đáp án C">
                                    <input name="optionD" type="text" placeholder="Đáp án D">
                                </div>
                                <div class="mock-correct-row">
                                    <select name="correctOption">
                                        <option value="A">Đúng: A</option>
                                        <option value="B">Đúng: B</option>
                                        <option value="C">Đúng: C</option>
                                        <option value="D">Đúng: D</option>
                                    </select>
                                    <input name="explanation" type="text" placeholder="Giải thích ngắn nếu có">
                                    <button type="button" class="btn-premium btn-secondary" onclick="removeMockBlock(this)">Xóa</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="mockEssayFields" style="display:none; gap:1rem;">
                        <div style="display:flex; justify-content:space-between; gap:1rem; align-items:center;">
                            <div>
                                <h3 style="margin:0; font-size:1rem; color:#0f172a;">Đề tự luận</h3>
                                <p style="margin:0.25rem 0 0; color:#64748b; font-weight:650;">Lưu đề dạng text và đáp án tham khảo.</p>
                            </div>
                            <button type="button" class="btn-premium btn-secondary" onclick="addMockEssayBlock()">Thêm đề tự luận</button>
                        </div>
                        <div id="mockEssayList" style="display:grid; gap:1rem;">
                            <div class="mock-essay-block">
                                <textarea name="essayPrompt" rows="4" placeholder="Nhập đề bài tự luận"></textarea>
                                <textarea name="essayReferenceAnswer" rows="4" placeholder="Gợi ý đáp án, dàn ý hoặc rubric tham khảo"></textarea>
                                <div style="display:flex; justify-content:flex-end;">
                                    <button type="button" class="btn-premium btn-secondary" onclick="removeMockBlock(this)">Xóa</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div style="display:flex; justify-content:flex-end; border-top:1px solid #e2e8f0; padding-top:1rem;">
                        <button type="submit" class="btn-premium btn-primary">Lưu đề thi thử</button>
                    </div>
                </form>
            </div>

            <div class="section-data-card">
                <div class="card-header-layout" style="padding:0 0 1rem 0; margin:0; background:transparent; border-bottom:1px solid #e2e8f0;">
                    <div class="card-header-title">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M8 6h13M8 12h13M8 18h13"/><path d="M3 6h.01M3 12h.01M3 18h.01"/></svg>
                        <span>Đề thi thử đã đăng</span>
                    </div>
                    <span style="font-size:0.78rem; font-weight:850; color:#2563eb; background:#eff6ff; padding:0.25rem 0.75rem; border-radius:999px;"><%= staffMockExams != null ? staffMockExams.size() : 0 %> đề</span>
                </div>

                <% if (staffMockExams != null && !staffMockExams.isEmpty()) { %>
                    <div style="overflow:auto; padding-top:1rem;">
                        <table style="width:100%; border-collapse:collapse; min-width:760px;">
                            <thead>
                                <tr style="text-align:left; color:#64748b; font-size:0.78rem; text-transform:uppercase; letter-spacing:0.04em;">
                                    <th style="padding:0.75rem; border-bottom:1px solid #e2e8f0;">Tên đề</th>
                                    <th style="padding:0.75rem; border-bottom:1px solid #e2e8f0;">Loại</th>
                                    <th style="padding:0.75rem; border-bottom:1px solid #e2e8f0;">Môn / khối</th>
                                    <th style="padding:0.75rem; border-bottom:1px solid #e2e8f0;">Nội dung</th>
                                    <th style="padding:0.75rem; border-bottom:1px solid #e2e8f0;">Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (MockExam exam : staffMockExams) { %>
                                    <tr>
                                        <td style="padding:0.9rem 0.75rem; border-bottom:1px solid #eef2f7; font-weight:850; color:#0f172a;"><%= h(exam.getTitle()) %></td>
                                        <td style="padding:0.9rem 0.75rem; border-bottom:1px solid #eef2f7;"><%= mockExamTypeLabel(exam.getExamType()) %></td>
                                        <td style="padding:0.9rem 0.75rem; border-bottom:1px solid #eef2f7; color:#475569;"><%= h(exam.getSubject()) %> · <%= h(exam.getGradeLevel()) %></td>
                                        <td style="padding:0.9rem 0.75rem; border-bottom:1px solid #eef2f7; color:#475569;"><%= exam.getItemCount() %> mục · <%= exam.getDurationMinutes() != null ? exam.getDurationMinutes() + " phút" : "Không giới hạn" %></td>
                                        <td style="padding:0.9rem 0.75rem; border-bottom:1px solid #eef2f7;"><%= mockExamStatusLabel(exam.getStatus()) %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div class="empty-status-panel" style="padding:3rem 2rem;">
                        <span style="font-weight:700; color:var(--text-main);">Chưa có đề thi thử thật</span>
                        <p style="font-size:0.85rem; max-width:440px; margin:0;">Staff tạo đề ở form phía trên, dữ liệu sẽ lưu vào mock_exams và bảng câu hỏi tương ứng.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</section>

<script>
function toggleMockExamTypeFields() {
    const typeSelect = document.getElementById('mockExamTypeSelect');
    const mcqFields = document.getElementById('mockMcqFields');
    const essayFields = document.getElementById('mockEssayFields');
    if (!typeSelect || !mcqFields || !essayFields) return;
    const isEssay = typeSelect.value === 'essay';
    mcqFields.style.display = isEssay ? 'none' : 'grid';
    essayFields.style.display = isEssay ? 'grid' : 'none';
}
function addMockQuestionBlock() {
    const list = document.getElementById('mockQuestionList');
    const first = list ? list.querySelector('.mock-question-block') : null;
    if (!list || !first) return;
    const clone = first.cloneNode(true);
    clone.querySelectorAll('input, textarea').forEach(input => input.value = '');
    clone.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
    list.appendChild(clone);
}
function addMockEssayBlock() {
    const list = document.getElementById('mockEssayList');
    const first = list ? list.querySelector('.mock-essay-block') : null;
    if (!list || !first) return;
    const clone = first.cloneNode(true);
    clone.querySelectorAll('textarea').forEach(input => input.value = '');
    list.appendChild(clone);
}
function removeMockBlock(button) {
    const block = button ? button.closest('.mock-question-block, .mock-essay-block') : null;
    if (!block || !block.parentElement) return;
    const siblings = block.parentElement.querySelectorAll('.mock-question-block, .mock-essay-block');
    if (siblings.length <= 1) {
        block.querySelectorAll('input, textarea').forEach(input => input.value = '');
        block.querySelectorAll('select').forEach(select => select.selectedIndex = 0);
        return;
    }
    block.remove();
}
document.addEventListener('DOMContentLoaded', toggleMockExamTypeFields);
</script>
