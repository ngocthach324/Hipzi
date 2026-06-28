<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@page import="com.hipzi.model.User" %>
        <% User user=(User) session.getAttribute("loggedUser"); String initials="H" ; if (user !=null) { if
            (user.getDisplayName() !=null && !user.getDisplayName().isEmpty()) { String[]
            parts=user.getDisplayName().trim().split("\\s+"); initials=parts[parts.length - 1].substring(0,
            1).toUpperCase(); } } %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>HIPZI - Nền tảng học tập thông minh cùng AI</title>
                <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/favicon.png">
                <link rel="dns-prefetch" href="//fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.googleapis.com" crossorigin>
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/landing.css?v=10">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/hero-v2.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/hipzi-chat-widget.css?v=4">
                <!-- Hiệu ứng cuộn mượt và chậm Lenis CSS -->
                <link rel="stylesheet" href="https://unpkg.com/lenis@1.1.13/dist/lenis.css">
                <script src="${pageContext.request.contextPath}/assets/js/page-transition.js" defer></script>
                <link rel="stylesheet"
                    href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=block">
            </head>

            <body>

                <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>

                    <!-- BỘ ĐIỀU HƯỚNG / NAVBAR -->
                    <header class="navbar">
                        <div class="nav-container">
                            <a href="${pageContext.request.contextPath}/index" class="logo">
                                <img src="${pageContext.request.contextPath}/assets/images/favicon.png"
                                    alt="HIPZI Logo">
                                <span>HIPZI</span>
                            </a>
                            <ul class="nav-links">

                                <li><a href="${pageContext.request.contextPath}/material-repository">Kho tài liệu</a></li>
                                <li><a href="${pageContext.request.contextPath}/classes">Lớp học</a></li>
                                <li><a href="${pageContext.request.contextPath}/mock-exams">Phòng thi</a></li>
                                <li><a href="${pageContext.request.contextPath}/courses">Khóa học</a></li>
                                <li><a href="${pageContext.request.contextPath}/index#ai-roadmap">Hipzi AI</a></li>
                            </ul>

                            <% if (user !=null) { %>
                                <div class="navbar-user-controls">
                                    <!-- Khung Dropdown Thông báo hệ thống cao cấp -->
                                    <%@ include file="/WEB-INF/fragments/cart-icon.jspf" %>
                                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                                        <!-- Khung Avatar Người dùng kèm Dropdown Menu -->
                                                                                <%@ include file="/WEB-INF/fragments/avatar-dropdown.jspf" %>
                                </div>
                                <% } else { %>
                                    <div class="nav-actions">
                                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Bắt
                                            đầu</a>
                                    </div>
                                    <% } %>
                        </div>
                    </header>

                    <!-- PHẦN HERO TRUYỀN CẢM HỨNG -->
                    <section class="hero-modern"
                        style="height: 100vh; width: 100%; display: flex; flex-direction: column; align-items: center; justify-content: flex-start; padding-top: 18vh; margin-top: -80px; background-color: #ffffff; background-image: url('${pageContext.request.contextPath}/assets/images/hero-lessonhero.png'); background-size: auto 160%; background-position: center calc(50% + 80px); background-repeat: no-repeat; position: relative;">
                        <h1 style="font-size: 2.75rem; font-weight: 800; color: #0f172a; max-width: 900px; text-align: center; line-height: 1.3; z-index: 10; padding: 0 20px; margin-bottom: 24px; <% if (user != null) { %>margin-top: 30px;<% } %>">
                            Học dễ hơn cùng HIPZI
                        </h1>
                        <% if (user==null) { %>
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary"
                                style="z-index: 10; padding: 12px 32px; font-size: 1rem; font-weight: 600; border-radius: 50px; box-shadow: 0 8px 20px rgba(5, 150, 105, 0.3);">
                                Khám phá ngay
                            </a>
                            <% } %>
                    </section>

                    <!-- PHẦN THỐNG KÊ / STATS SECTION -->
                    <section class="stats-section">
                        <div class="stats-container reveal-up">
                            <div class="stats-header">
                                <div class="stats-header-text">
                                    <h3>Những con số biết nói</h3>
                                    <p>HIPZI không chỉ hứa hẹn, chúng tôi mang lại kết quả thực tế. Đôi khi hơi khó tin,
                                        nhưng đây là sự thật.</p>
                                </div>
                                <div class="stats-header-actions">
                                    <% if (user==null) { %>
                                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">Bắt
                                            đầu ngay</a>
                                        <% } else { %>
                                            <a href="${pageContext.request.contextPath}/material-repository"
                                                class="btn btn-primary">Khám phá tài liệu</a>
                                            <% } %>
                                </div>
                            </div>
                            <div class="stats-grid">
                                <div class="stat-card">
                                    <div class="stat-number"><span class="stat-counter" data-target="10">0</span>K+
                                    </div>
                                    <div class="stat-label">Tài liệu học tập</div>
                                    <p class="stat-desc">Đa dạng môn học và cấp độ, được cập nhật liên tục.</p>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-number"><span class="stat-counter" data-target="21.2">0</span>K+
                                    </div>
                                    <div class="stat-label">Học viên tích cực</div>
                                    <p class="stat-desc">Hàng ngàn học viên đang cải thiện kết quả mỗi ngày.</p>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-number"><span class="stat-counter" data-target="500">0</span>+
                                    </div>
                                    <div class="stat-label">Khóa học & Bài thi</div>
                                    <p class="stat-desc">Hệ thống bài giảng bám sát chương trình thực tế.</p>
                                </div>
                                <div class="stat-card">
                                    <div class="stat-number"><span class="stat-counter" data-target="100">0</span>+
                                    </div>
                                    <div class="stat-label">Giảng viên uy tín</div>
                                    <p class="stat-desc">Đội ngũ giáo viên giàu kinh nghiệm đồng hành cùng bạn.</p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- PHẦN CÁC TÍNH NĂNG NỔI BẬT / FEATURES -->
                    <section class="features">
                        <h2 class="section-title ecosystem-title" data-highlight-text="toàn diện">Hệ sinh thái học tập toàn diện</h2>
                        <p class="section-subtitle">Chuyển đổi các nội dung giáo dục tĩnh thành trải nghiệm học tập
                            tương tác, cá nhân hóa và tràn đầy cảm hứng.</p>

                        <div class="features-grid">
                            <!-- Card 1 -->
                            <div class="feature-card">
                                <div class="feature-icon icon-primary">
                                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                                        <polyline points="14 2 14 8 20 8"></polyline>
                                        <path d="M9 15l2 2 4-4"></path>
                                    </svg>
                                </div>
                                <h3>Học liệu chuẩn kiểm duyệt</h3>
                                <p>Kho tài liệu phong phú được đóng góp từ các Giảng viên uy tín trên toàn quốc.</p>
                                <ul class="feature-list">
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>100% Đã qua kiểm duyệt chất lượng</span>
                                    </li>
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Đa dạng định dạng: PDF, DOCX, PPTX...</span>
                                    </li>
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Cập nhật liên tục theo chương trình học</span>
                                    </li>
                                </ul>
                                <a href="<%= request.getContextPath() + (user != null ? " /material-repository"
                                    : "/login" ) %>" class="feature-link">
                                    <span>Khám phá ngay</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2.5">
                                        <path d="M5 12h14M12 5l7 7-7 7" />
                                    </svg>
                                </a>
                            </div>

                            <!-- Card 2 -->
                            <div class="feature-card">
                                <div class="feature-icon icon-secondary">
                                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <rect x="5" y="3" width="14" height="18" rx="2"></rect>
                                        <path d="M9 7h6"></path>
                                        <path d="M9 11h6"></path>
                                        <path d="M9 15h3"></path>
                                        <path d="M14 16l1.5 1.5L19 14"></path>
                                    </svg>
                                </div>
                                <h3>Phòng thi trực tuyến</h3>
                                <p>Luyện đề, làm bài kiểm tra trong lớp và tham gia các kỳ thi chung của HIPZI trong một
                                    không gian tập trung.</p>
                                <ul class="feature-list">
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Luyện đề mở theo từng mục tiêu</span>
                                    </li>
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Bài kiểm tra lớp học rõ thời hạn</span>
                                    </li>
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Kỳ thi chung có kết quả minh bạch</span>
                                    </li>
                                </ul>
                                <a href="<%= request.getContextPath() + (user != null ? " /exam-room" : "/login" ) %>"
                                    class="feature-link" style="color: var(--secondary-hover);">
                                    <span>Vào phòng thi</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2.5">
                                        <path d="M5 12h14M12 5l7 7-7 7" />
                                    </svg>
                                </a>
                            </div>

                            <!-- Card 3 -->
                            <div class="feature-card">
                                <div class="feature-icon icon-accent">
                                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path>
                                        <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path>
                                    </svg>
                                </div>
                                <h3>Khóa học đa dạng</h3>
                                <p>Hệ thống khóa học chất lượng cao được thiết kế theo lộ trình chuẩn giúp bạn dễ dàng
                                    chinh phục mục tiêu.</p>
                                <ul class="feature-list">
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Lộ trình bài bản, cá nhân hóa</span>
                                    </li>
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Video bài giảng trực quan</span>
                                    </li>
                                    <li>
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#059669"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <path d="M8 12l2 2 6-6" />
                                        </svg>
                                        <span>Tương tác với giảng viên</span>
                                    </li>
                                </ul>
                                <a href="<%= request.getContextPath() + (user != null ? " /courses" : "/login" ) %>"
                                    class="feature-link" style="color: var(--primary);">
                                    <span>Trải nghiệm ngay</span>
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2.5">
                                        <path d="M5 12h14M12 5l7 7-7 7" />
                                    </svg>
                                </a>
                            </div>
                        </div>
                    </section>

                    <!-- PHẦN CÁC MÔN HỌC / SUBJECTS SECTION -->
                    <section class="subjects-section">
                        <div class="subjects-frame">
                            <div class="subjects-section-header">
                                <h2 class="section-title scroll-letter-title subjects-section-title"
                                    data-accent-text="12">Khám phá 12 môn học nổi bật</h2>
                                <p class="subjects-section-description typewriter-text">Khám phá lộ trình học tập theo
                                    từng môn với tài liệu, lớp học và bộ câu hỏi luyện tập được sắp xếp rõ ràng cho từng
                                    mục tiêu.</p>
                            </div>

                            <div class="subjects-mascot" aria-hidden="true">
                                <img src="${pageContext.request.contextPath}/assets/images/subjects_mascot_cutout.png"
                                    alt="">
                                <span class="mascot-subject-icon mascot-subject-icon--math">&pi;</span>
                                <span class="mascot-subject-icon mascot-subject-icon--chem">H2O</span>
                                <span class="mascot-subject-icon mascot-subject-icon--eng">Aa</span>
                                <span class="mascot-subject-icon mascot-subject-icon--code">{ }</span>
                            </div>

                            <div class="subjects-panel">
                                <div class="subjects-book-stage">
                                    <div class="subjects-book">
                                        <span class="subjects-book-cover subjects-book-cover--left"></span>
                                        <span class="subjects-book-cover subjects-book-cover--right"></span>
                                        <span class="subjects-book-page subjects-book-page--left"></span>
                                        <span class="subjects-book-page subjects-book-page--right"></span>
                                        <span class="subjects-book-spine"></span>
                                        <span class="subjects-book-turning-page"></span>

                                        <div class="subjects-panel-copy">
                                            <div class="subjects-panel-topline">
                                                <span class="subjects-kicker" id="subjectKicker">Chọn môn học</span>
                                                <span class="subjects-panel-badge">Lộ trình cá nhân hóa</span>
                                            </div>
                                            <h2 class="section-title" id="subjectTitle">Toán học</h2>
                                            <p class="section-subtitle" id="subjectDescription">Rèn tư duy logic, đại
                                                số, hình học và kỹ năng giải đề theo lộ trình rõ ràng từ nền tảng đến
                                                nâng cao.</p>
                                            <div class="subjects-focus-wrap">
                                                <span class="subjects-focus-icon" aria-hidden="true">
                                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.4" stroke-linecap="round"
                                                        stroke-linejoin="round">
                                                        <path d="M12 3v18" />
                                                        <path d="M5 8h14" />
                                                        <path d="M7 16h10" />
                                                    </svg>
                                                </span>
                                                <div class="subjects-focus" id="subjectFocus">Trọng tâm: Đại số, hình
                                                    học, xác suất và luyện đề THPT.</div>
                                            </div>
                                            <div class="subjects-action-row">
                                                <a href="${pageContext.request.contextPath}/material-repository?subject=Toán"
                                                    class="subjects-cta" id="subjectCta">
                                                    <span>Xem tài liệu môn này</span>
                                                    <svg width="17" height="17" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.5">
                                                        <path d="M5 12h14M12 5l7 7-7 7" />
                                                    </svg>
                                                </a>
                                            </div>
                                        </div>

                                        <div class="subjects-insight">
                                            <div class="subjects-insight-header">
                                                <span>Tổng quan môn học</span>
                                                <strong>HIPZI</strong>
                                            </div>
                                            <div class="subjects-metrics" aria-label="Số liệu môn học">
                                                <div class="subject-metric">
                                                    <span class="subject-metric-value"
                                                        id="subjectClassCount">100+</span>
                                                    <span class="subject-metric-label">Lớp học</span>
                                                </div>
                                                <div class="subject-metric">
                                                    <span class="subject-metric-value"
                                                        id="subjectMaterialCount">230+</span>
                                                    <span class="subject-metric-label">Tài liệu</span>
                                                </div>
                                                <div class="subject-metric">
                                                    <span class="subject-metric-value" id="subjectQuizCount">180+</span>
                                                    <span class="subject-metric-label">Quiz</span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="subjects-card-shell">
                                <button type="button" class="subjects-page-btn subjects-page-prev"
                                    aria-label="Xem nhóm môn học trước">&lt;</button>
                                <div class="subjects-card-row" aria-label="Các môn học nổi bật" role="tablist">
                                    <button type="button" class="subject-card subject-card--math active" role="tab"
                                        aria-selected="true" data-title="Toán học"
                                        data-description="Rèn tư duy logic, đại số, hình học và kỹ năng giải đề theo lộ trình rõ ràng từ nền tảng đến nâng cao."
                                        data-focus="Trọng tâm: Đại số, hình học, xác suất và luyện đề THPT."
                                        data-class-count="100+" data-material-count="230+" data-quiz-count="180+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Toán">
                                        <span class="subject-icon subject-icon--math" aria-hidden="true">
                                            <span class="icon-calc-screen"></span>
                                            <span class="icon-calc-key"></span>
                                            <span class="icon-calc-key"></span>
                                            <span class="icon-calc-key icon-calc-key--hot"></span>
                                            <span class="icon-calc-key"></span>
                                            <span class="icon-calc-key"></span>
                                            <span class="icon-calc-key icon-calc-key--tall"></span>
                                        </span>
                                        <span class="subject-name">Toán học</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--physics" role="tab"
                                        aria-selected="false" data-title="Vật lý"
                                        data-description="Khám phá chuyển động, điện, quang và các hiện tượng tự nhiên qua hệ thống bài giảng dễ nắm bắt."
                                        data-focus="Trọng tâm: Cơ học, điện học, dao động và luyện bài tập định lượng."
                                        data-class-count="85+" data-material-count="200+" data-quiz-count="150+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Lý">
                                        <span class="subject-icon subject-icon--physics" aria-hidden="true">
                                            <span class="icon-atom-orbit"></span>
                                            <span class="icon-atom-orbit"></span>
                                            <span class="icon-atom-orbit"></span>
                                            <span class="icon-atom-core"></span>
                                        </span>
                                        <span class="subject-name">Vật lý</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--chemistry" role="tab"
                                        aria-selected="false" data-title="Hóa học"
                                        data-description="Nắm chắc bản chất phản ứng, công thức và phương pháp xử lý bài tập hóa học theo từng chuyên đề."
                                        data-focus="Trọng tâm: Hóa hữu cơ, vô cơ, phản ứng và bài toán mol."
                                        data-class-count="90+" data-material-count="210+" data-quiz-count="165+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Hóa">
                                        <span class="subject-icon subject-icon--chemistry" aria-hidden="true">
                                            <span class="icon-flask-neck"></span>
                                            <span class="icon-flask-body"></span>
                                            <span class="icon-flask-liquid"></span>
                                            <span class="icon-flask-bubble"></span>
                                        </span>
                                        <span class="subject-name">Hóa học</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--english" role="tab"
                                        aria-selected="false" data-title="Tiếng Anh"
                                        data-description="Xây nền từ vựng, ngữ pháp, đọc hiểu và kỹ năng làm bài qua các bộ tài liệu luyện tập có cấu trúc."
                                        data-focus="Trọng tâm: Từ vựng, ngữ pháp, đọc hiểu và luyện đề chuẩn hóa."
                                        data-class-count="120+" data-material-count="260+" data-quiz-count="230+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Anh">
                                        <span class="subject-icon subject-icon--english" aria-hidden="true">
                                            <span class="icon-chat-dot"></span>
                                            <span class="icon-chat-dot"></span>
                                            <span class="icon-chat-dot"></span>
                                        </span>
                                        <span class="subject-name">Tiếng Anh</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--literature" role="tab"
                                        aria-selected="false" data-title="Ngữ văn"
                                        data-description="Bồi dưỡng năng lực đọc hiểu, cảm thụ văn học và kỹ năng viết bài nghị luận rõ ý, giàu lập luận."
                                        data-focus="Trọng tâm: Đọc hiểu, nghị luận xã hội, nghị luận văn học và kỹ năng diễn đạt."
                                        data-class-count="75+" data-material-count="190+" data-quiz-count="120+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Văn">
                                        <span class="subject-icon subject-icon--literature" aria-hidden="true">
                                            <span class="icon-book-page icon-book-page--left"></span>
                                            <span class="icon-book-page icon-book-page--right"></span>
                                            <span class="icon-book-line"></span>
                                            <span class="icon-book-line"></span>
                                            <span class="icon-book-line"></span>
                                        </span>
                                        <span class="subject-name">Ngữ văn</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--biology" role="tab"
                                        aria-selected="false" data-title="Sinh học"
                                        data-description="Hệ thống hóa kiến thức tế bào, di truyền, tiến hóa và sinh thái bằng sơ đồ, câu hỏi và bài luyện tập."
                                        data-focus="Trọng tâm: Di truyền học, sinh thái, cơ thể người và luyện câu hỏi vận dụng."
                                        data-class-count="70+" data-material-count="170+" data-quiz-count="135+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Sinh Học">
                                        <span class="subject-icon subject-icon--biology" aria-hidden="true">
                                            <span class="icon-dna-rail icon-dna-rail--left"></span>
                                            <span class="icon-dna-rail icon-dna-rail--right"></span>
                                            <span class="icon-dna-rung"></span>
                                            <span class="icon-dna-rung"></span>
                                            <span class="icon-dna-rung"></span>
                                        </span>
                                        <span class="subject-name">Sinh học</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--history" role="tab"
                                        aria-selected="false" data-title="Lịch sử"
                                        data-description="Nắm mạch sự kiện, nhân vật và bối cảnh lịch sử qua tài liệu tóm tắt, timeline và câu hỏi ôn tập."
                                        data-focus="Trọng tâm: Mốc thời gian, sự kiện trọng điểm và luyện câu hỏi nhận biết - thông hiểu."
                                        data-class-count="60+" data-material-count="150+" data-quiz-count="110+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Lịch Sử">
                                        <span class="subject-icon subject-icon--history" aria-hidden="true">
                                            <span class="icon-scroll-body"></span>
                                            <span class="icon-scroll-rod icon-scroll-rod--top"></span>
                                            <span class="icon-scroll-rod icon-scroll-rod--bottom"></span>
                                            <span class="icon-scroll-line"></span>
                                            <span class="icon-scroll-line"></span>
                                        </span>
                                        <span class="subject-name">Lịch sử</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--geography" role="tab"
                                        aria-selected="false" data-title="Địa lý"
                                        data-description="Luyện đọc Atlat, phân tích biểu đồ, xử lý số liệu và ghi nhớ kiến thức vùng miền theo hệ thống."
                                        data-focus="Trọng tâm: Atlat, biểu đồ, địa lý tự nhiên, kinh tế và vùng lãnh thổ."
                                        data-class-count="65+" data-material-count="155+" data-quiz-count="115+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Địa Lý">
                                        <span class="subject-icon subject-icon--geography" aria-hidden="true">
                                            <span class="icon-globe"></span>
                                            <span class="icon-globe-line icon-globe-line--lat"></span>
                                            <span class="icon-globe-line icon-globe-line--lng"></span>
                                            <span class="icon-map-pin"></span>
                                        </span>
                                        <span class="subject-name">Địa lý</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--technology" role="tab"
                                        aria-selected="false" data-title="Công nghệ"
                                        data-description="Khám phá thiết kế kỹ thuật, quy trình sản xuất, công nghệ số và cách ứng dụng kiến thức vào đời sống."
                                        data-focus="Trọng tâm: Thiết kế kỹ thuật, hệ thống công nghệ, quy trình và ứng dụng thực tiễn."
                                        data-class-count="45+" data-material-count="100+" data-quiz-count="80+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Công Nghệ">
                                        <span class="subject-icon subject-icon--informatics" aria-hidden="true">
                                            <span class="icon-laptop-screen"></span>
                                            <span class="icon-laptop-base"></span>
                                            <span class="icon-code-mark icon-code-mark--left"></span>
                                            <span class="icon-code-mark icon-code-mark--right"></span>
                                        </span>
                                        <span class="subject-name">Công nghệ</span>
                                    </button>
                                    <button type="button" class="subject-card subject-card--informatics" role="tab"
                                        aria-selected="false" data-title="Tin học"
                                        data-description="Xây nền tư duy thuật toán, kỹ năng sử dụng công cụ số và thực hành lập trình từ cơ bản đến nâng cao."
                                        data-focus="Trọng tâm: Thuật toán, Python, bảng tính, dữ liệu và kỹ năng số."
                                        data-class-count="80+" data-material-count="180+" data-quiz-count="140+"
                                        data-href="<%= request.getContextPath() %>/material-repository?subject=Tin Học">
                                        <span class="subject-icon subject-icon--informatics" aria-hidden="true">
                                            <span class="icon-laptop-screen"></span>
                                            <span class="icon-laptop-base"></span>
                                            <span class="icon-code-mark icon-code-mark--left"></span>
                                            <span class="icon-code-mark icon-code-mark--right"></span>
                                        </span>
                                        <span class="subject-name">Tin học</span>
                                    </button>
                                </div>
                                <button type="button" class="subjects-page-btn subjects-page-next"
                                    aria-label="Xem nhóm môn học tiếp theo">&gt;</button>
                            </div>
                        </div>
                    </section>

                    <!-- PHẦN CÁCH HIPZI HOẠT ĐỘNG / HOW HIPZI WORKS SECTION -->
                    <section class="hipzi-how-section" id="hipzi-how-section" aria-labelledby="hipziHowTitle">
                        <div class="hipzi-how-container">
                            <header class="hipzi-how-header">
                                <h2 class="section-title scroll-letter-title hipzi-how-title" id="hipziHowTitle"
                                    data-accent-text="hiệu quả" data-accent-char="4">4 tính năng giúp học tập hiệu quả
                                </h2>
                                <p class="hipzi-how-subtitle">Khám phá kho tài liệu, tham gia lớp học, ôn tập thông minh
                                    và kết nối với giảng viên để đạt kết quả học tập tốt nhất.</p>
                            </header>

                            <div class="stacking-cards-container" id="stacking-cards">
                                <div class="stacking-card card-1">
                                    <div class="sc-content">
                                        <div class="sc-image">
                                            <img src="${pageContext.request.contextPath}/assets/images/card_1_docs.png"
                                                alt="Kho tài liệu">
                                        </div>
                                        <div class="sc-text">
                                            <span class="sc-eyebrow">01 / TÀI LIỆU</span>
                                            <h3>Kho tài liệu</h3>
                                            <p>Khám phá tài liệu học tập được sắp xếp theo môn học, chủ đề và cấp độ,
                                                giúp bạn tìm đúng nội dung cần học nhanh hơn.</p>
                                            <div class="sc-tags">
                                                <span class="sc-tag">Đa dạng</span>
                                                <span class="sc-tag">Dễ tìm kiếm</span>
                                                <span class="sc-tag">Chất lượng</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="stacking-card card-2">
                                    <div class="sc-content">
                                        <div class="sc-image">
                                            <img src="${pageContext.request.contextPath}/assets/images/card_2_class.png"
                                                alt="Lớp học">
                                        </div>
                                        <div class="sc-text">
                                            <span class="sc-eyebrow">02 / LỚP HỌC</span>
                                            <h3>Lớp học</h3>
                                            <p>Tham gia các lớp học phù hợp với mục tiêu của bạn, theo dõi bài học, tài
                                                liệu và hoạt động học tập trong cùng một không gian.</p>
                                            <div class="sc-tags">
                                                <span class="sc-tag">Tương tác</span>
                                                <span class="sc-tag">Tiến độ</span>
                                                <span class="sc-tag">Tập trung</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="stacking-card card-3">
                                    <div class="sc-content">
                                        <div class="sc-image">
                                            <img src="${pageContext.request.contextPath}/assets/images/card_3_exam.png"
                                                alt="Phòng thi">
                                        </div>
                                        <div class="sc-text">
                                            <span class="sc-eyebrow">03 / PHÒNG THI</span>
                                            <h3>Phòng thi</h3>
                                            <p>Trải nghiệm các bài thi thử với cấu trúc chuẩn và thời gian thực, giúp
                                                bạn đánh giá năng lực và tự tin bước vào kỳ thi chính thức.</p>
                                            <div class="sc-tags">
                                                <span class="sc-tag">Đề thi chuẩn</span>
                                                <span class="sc-tag">Chấm điểm ngay</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="stacking-card card-4">
                                    <div class="sc-content">
                                        <div class="sc-image">
                                            <img src="${pageContext.request.contextPath}/assets/images/card_4_course.png"
                                                alt="Khóa học">
                                        </div>
                                        <div class="sc-text">
                                            <span class="sc-eyebrow">04 / KHÓA HỌC</span>
                                            <h3>Khóa học</h3>
                                            <p>Tham gia các khóa học chuyên sâu được thiết kế bài bản bởi đội ngũ giáo
                                                viên giàu kinh nghiệm với lộ trình rõ ràng giúp đạt điểm cao.</p>
                                            <div class="sc-tags">
                                                <span class="sc-tag">Chuyên sâu</span>
                                                <span class="sc-tag">Lộ trình chuẩn</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <script>
                                document.addEventListener("DOMContentLoaded", function () {
                                    const container = document.querySelector('.stacking-cards-container');
                                    const cards = document.querySelectorAll('.stacking-card');
                                    if (!container || !cards.length) return;

                                    let isTicking = false;

                                    // Tối ưu hóa: Tính toán chiều cao lớn nhất 1 lần (và khi resize) để tránh giật lag khi cuộn
                                    const balanceHeights = () => {
                                        let maxHeight = 0;
                                        cards.forEach(card => {
                                            card.style.height = 'auto'; // Reset để lấy chiều cao tự nhiên
                                            if (card.offsetHeight > maxHeight) {
                                                maxHeight = card.offsetHeight;
                                            }
                                        });
                                        cards.forEach(card => {
                                            card.style.height = maxHeight + 'px'; // Đồng bộ chiều cao
                                        });
                                    };

                                    // Cân bằng chiều cao ngay khi tải trang
                                    balanceHeights();

                                    // Cập nhật lại chiều cao nếu người dùng thay đổi kích thước cửa sổ
                                    window.addEventListener('resize', () => {
                                        balanceHeights();
                                    });

                                    const updateCards = () => {
                                        const containerTop = container.getBoundingClientRect().top;

                                        cards.forEach((card) => {
                                            const stickyTop = parseInt(window.getComputedStyle(card).top, 10) || 100;
                                            const originalTop = containerTop + card.offsetTop;
                                            const scrolledPast = stickyTop - originalTop;

                                            if (scrolledPast > 0) {
                                                const effectDistance = 1200;
                                                let progress = scrolledPast / effectDistance;
                                                if (progress > 1) progress = 1;

                                                // Tăng độ sâu 3D: Thu nhỏ tối đa 20% (còn 0.80) và làm tối tối đa 60%
                                                const scale = 1 - (0.20 * progress);
                                                const brightness = 1 - (0.6 * progress);

                                                card.style.transform = `scale(${scale})`;
                                                card.style.filter = `brightness(${brightness})`;
                                            } else {
                                                card.style.transform = `scale(1)`;
                                                card.style.filter = 'brightness(1)';
                                            }
                                        });
                                        isTicking = false;
                                    };

                                    window.addEventListener('scroll', () => {
                                        if (!isTicking) {
                                            window.requestAnimationFrame(updateCards);
                                            isTicking = true;
                                        }
                                    }, { passive: true });

                                    // Khởi chạy tính toán ngay khi tải trang
                                    updateCards();
                                });
                            </script>
                        </div>
                    </section>

                    <!-- PHẦN LỘ TRÌNH HỌC TẬP AI / AI ROADMAP SECTION -->
                    <section id="ai-roadmap" class="ai-roadmap-section">
                        <div class="ai-roadmap-header">
                            <h2 class="section-title scroll-letter-title ai-roadmap-title" data-accent-text="HIPZI AI"
                                data-accent-mode="brand-bounce">Xây dựng lộ trình học tập cùng HIPZI AI</h2>
                            <p class="section-subtitle typewriter-text">HIPZI AI đồng hành cùng bạn từ việc xác định mục
                                tiêu, gợi ý lộ trình, cung cấp tài liệu đến luyện tập và theo dõi tiến độ học tập.</p>
                        </div>

                        <div class="ai-roadmap-shell" aria-label="Các bước xây dựng lộ trình học tập cùng HIPZI AI">
                            <article class="ai-roadmap-step">
                                <div class="ai-roadmap-step-index">01</div>
                                <div class="ai-roadmap-step-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"
                                        stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="12" cy="12" r="8" />
                                        <circle cx="12" cy="12" r="3" />
                                        <path d="M12 2v3" />
                                        <path d="M12 19v3" />
                                        <path d="M2 12h3" />
                                        <path d="M19 12h3" />
                                    </svg>
                                </div>
                                <h3>Chọn mục tiêu học tập</h3>
                                <p>Bạn bắt đầu bằng cách chọn môn học, cấp độ hoặc mục tiêu cụ thể như ôn thi, củng cố
                                    kiến thức hay học theo lộ trình.</p>
                            </article>

                            <article class="ai-roadmap-step">
                                <div class="ai-roadmap-step-index">02</div>
                                <div class="ai-roadmap-step-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"
                                        stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M4 19V6a2 2 0 0 1 2-2h2" />
                                        <path d="M16 4h2a2 2 0 0 1 2 2v13" />
                                        <path d="M8 4h8" />
                                        <path d="M7 19c2.2-4 7.8-4 10 0" />
                                        <path d="M12 8v5" />
                                        <path d="m9.5 10.5 2.5 2.5 2.5-2.5" />
                                    </svg>
                                </div>
                                <h3>HIPZI AI đề xuất lộ trình</h3>
                                <p>Dựa trên mục tiêu của bạn, AI sẽ gợi ý lộ trình học phù hợp, chia nhỏ nội dung theo
                                    từng chủ đề và mức độ.</p>
                            </article>

                            <article class="ai-roadmap-step">
                                <div class="ai-roadmap-step-index">03</div>
                                <div class="ai-roadmap-step-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"
                                        stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                        <path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5z" />
                                        <path d="M8 7h8" />
                                        <path d="M8 11h6" />
                                    </svg>
                                </div>
                                <h3>Học với tài liệu phù hợp</h3>
                                <p>Mỗi bài học được liên kết với tài liệu, video, ghi chú hoặc nội dung tóm tắt giúp bạn
                                    học nhanh và dễ hiểu hơn.</p>
                            </article>

                            <article class="ai-roadmap-step">
                                <div class="ai-roadmap-step-index">04</div>
                                <div class="ai-roadmap-step-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"
                                        stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M9 11h6" />
                                        <path d="M9 15h3" />
                                        <path d="M7 3h10a2 2 0 0 1 2 2v14l-3-2-3 2-3-2-3 2V5a2 2 0 0 1 2-2z" />
                                        <path d="m15 14 1.4 1.4L20 12" />
                                    </svg>
                                </div>
                                <h3>Luyện tập bằng câu hỏi thông minh</h3>
                                <p>HIPZI AI tạo bộ câu hỏi luyện tập theo từng chủ đề, giúp bạn kiểm tra mức độ hiểu bài
                                    và ghi nhớ kiến thức.</p>
                            </article>

                            <article class="ai-roadmap-step">
                                <div class="ai-roadmap-step-index">05</div>
                                <div class="ai-roadmap-step-icon" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"
                                        stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M4 19V5" />
                                        <path d="M4 19h16" />
                                        <path d="M8 16v-4" />
                                        <path d="M12 16V8" />
                                        <path d="M16 16v-6" />
                                        <path d="m17 7 3-3" />
                                        <path d="M20 4v4" />
                                        <path d="M20 4h-4" />
                                    </svg>
                                </div>
                                <h3>Theo dõi tiến độ & cải thiện</h3>
                                <p>Sau mỗi buổi học, hệ thống ghi nhận kết quả, chỉ ra điểm mạnh, điểm yếu và đề xuất
                                    nội dung nên học tiếp theo.</p>
                            </article>
                        </div>

                        <div class="ai-roadmap-action">
                            <a class="ai-roadmap-cta" href="${pageContext.request.contextPath}/login">Bắt đầu với HIPZI
                                AI <span aria-hidden="true">›</span></a>
                        </div>
                    </section>

                    <!-- PHẦN ĐÁNH GIÁ TỪ CỘNG ĐỒNG / TESTIMONIALS SECTION -->
                    <section class="testimonials-section">
                        <div style="text-align: center; margin-bottom: 3.5rem;">
                            <h2 class="section-title ecosystem-title scroll-letter-title"
                                data-highlight-text="cộng đồng">Đánh giá từ cộng đồng</h2>
                            <p class="section-subtitle" style="margin-bottom: 0;">Hàng ngàn Học viên và Giảng viên trên
                                toàn quốc đã tin tưởng lựa chọn HIPZI làm bạn đồng hành.</p>
                        </div>

                        <div class="marquee-wrapper">
                            <div class="marquee-track">
                                <!-- Group 1 -->
                                <div class="marquee-group">
                                    <!-- Card 1 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Giao diện rất chuyên nghiệp và dễ sử dụng.
                                                Mình tìm kiếm tài liệu trọng tâm ôn thi THPT Quốc gia chỉ mất vài giây."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #2563eb;">ĐH</div>
                                            <div class="author-info">
                                                <div class="author-name">Đức Huy</div>
                                                <div class="author-role">Học sinh lớp 12</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 2 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Cảm ơn HIPZI đã duy trì nền tảng chất lượng.
                                                Các bộ flashcard tự động tạo từ tài liệu giúp mình nhớ bài cực kỳ lâu."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f59e0b;">TH</div>
                                            <div class="author-info">
                                                <div class="author-name">Lê Thu Hương</div>
                                                <div class="author-role">Học sinh lớp 11</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 3 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Tính năng luyện đề trắc nghiệm AI rất sát với
                                                thực tế. Mình đã đạt kết quả cao trong kỳ thi giữa kỳ nhờ ôn luyện tại
                                                đây."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #8b5cf6;">QH</div>
                                            <div class="author-info">
                                                <div class="author-name">Phạm Quang Huy</div>
                                                <div class="author-role">Sinh viên CNTT</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 4 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Các box học tập rất hay và trực quan. Giao
                                                diện thân thiện tiếp thêm động lực học mỗi ngày cho mình và bạn bè."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f43f5e;">NL</div>
                                            <div class="author-info">
                                                <div class="author-name">Võ Ngọc Linh</div>
                                                <div class="author-role">Học sinh lớp 10</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 5 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Quy trình kiểm duyệt giúp kho học liệu luôn
                                                giữ tiêu chuẩn cao. Công cụ AI hỗ trợ tạo câu hỏi giúp tôi tiết kiệm 80%
                                                thời gian."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #059669;">MT</div>
                                            <div class="author-info">
                                                <div class="author-name">Trần Minh Tuấn</div>
                                                <div class="author-role">Giảng viên Toán</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Group 2 (Duplicated for Seamless Infinite Looping) -->
                                <div class="marquee-group" aria-hidden="true">
                                    <!-- Card 1 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Giao diện rất chuyên nghiệp và dễ sử dụng.
                                                Mình tìm kiếm tài liệu trọng tâm ôn thi THPT Quốc gia chỉ mất vài giây."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #2563eb;">ĐH</div>
                                            <div class="author-info">
                                                <div class="author-name">Đức Huy</div>
                                                <div class="author-role">Học sinh lớp 12</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 2 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Cảm ơn HIPZI đã duy trì nền tảng chất lượng.
                                                Các bộ flashcard tự động tạo từ tài liệu giúp mình nhớ bài cực kỳ lâu."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f59e0b;">TH</div>
                                            <div class="author-info">
                                                <div class="author-name">Lê Thu Hương</div>
                                                <div class="author-role">Học sinh lớp 11</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 3 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Tính năng luyện đề trắc nghiệm AI rất sát với
                                                thực tế. Mình đã đạt kết quả cao trong kỳ thi giữa kỳ nhờ ôn luyện tại
                                                đây."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #8b5cf6;">QH</div>
                                            <div class="author-info">
                                                <div class="author-name">Phạm Quang Huy</div>
                                                <div class="author-role">Sinh viên CNTT</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 4 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Các box học tập rất hay và trực quan. Giao
                                                diện thân thiện tiếp thêm động lực học mỗi ngày cho mình và bạn bè."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f43f5e;">NL</div>
                                            <div class="author-info">
                                                <div class="author-name">Võ Ngọc Linh</div>
                                                <div class="author-role">Học sinh lớp 10</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 5 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Quy trình kiểm duyệt giúp kho học liệu luôn
                                                giữ tiêu chuẩn cao. Công cụ AI hỗ trợ tạo câu hỏi giúp tôi tiết kiệm 80%
                                                thời gian."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #059669;">MT</div>
                                            <div class="author-info">
                                                <div class="author-name">Trần Minh Tuấn</div>
                                                <div class="author-role">Giảng viên Toán</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="marquee-track" style="margin-top: 2rem;">
                                <!-- Group 1 -->
                                <div class="marquee-group-reverse">
                                    <!-- Card 1 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Giao diện rất chuyên nghiệp và dễ sử dụng.
                                                Mình tìm kiếm tài liệu trọng tâm ôn thi THPT Quốc gia chỉ mất vài giây."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #2563eb;">ĐH</div>
                                            <div class="author-info">
                                                <div class="author-name">Đức Huy</div>
                                                <div class="author-role">Học sinh lớp 12</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 2 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Cảm ơn HIPZI đã duy trì nền tảng chất lượng.
                                                Các bộ flashcard tự động tạo từ tài liệu giúp mình nhớ bài cực kỳ lâu."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f59e0b;">TH</div>
                                            <div class="author-info">
                                                <div class="author-name">Lê Thu Hương</div>
                                                <div class="author-role">Học sinh lớp 11</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 3 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Tính năng luyện đề trắc nghiệm AI rất sát với
                                                thực tế. Mình đã đạt kết quả cao trong kỳ thi giữa kỳ nhờ ôn luyện tại
                                                đây."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #8b5cf6;">QH</div>
                                            <div class="author-info">
                                                <div class="author-name">Phạm Quang Huy</div>
                                                <div class="author-role">Sinh viên CNTT</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 4 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Các box học tập rất hay và trực quan. Giao
                                                diện thân thiện tiếp thêm động lực học mỗi ngày cho mình và bạn bè."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f43f5e;">NL</div>
                                            <div class="author-info">
                                                <div class="author-name">Võ Ngọc Linh</div>
                                                <div class="author-role">Học sinh lớp 10</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 5 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Quy trình kiểm duyệt giúp kho học liệu luôn
                                                giữ tiêu chuẩn cao. Công cụ AI hỗ trợ tạo câu hỏi giúp tôi tiết kiệm 80%
                                                thời gian."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #059669;">MT</div>
                                            <div class="author-info">
                                                <div class="author-name">Trần Minh Tuấn</div>
                                                <div class="author-role">Giảng viên Toán</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Group 2 (Duplicated for Seamless Infinite Looping) -->
                                <div class="marquee-group-reverse" aria-hidden="true">
                                    <!-- Card 1 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Giao diện rất chuyên nghiệp và dễ sử dụng.
                                                Mình tìm kiếm tài liệu trọng tâm ôn thi THPT Quốc gia chỉ mất vài giây."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #2563eb;">ĐH</div>
                                            <div class="author-info">
                                                <div class="author-name">Đức Huy</div>
                                                <div class="author-role">Học sinh lớp 12</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 2 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Cảm ơn HIPZI đã duy trì nền tảng chất lượng.
                                                Các bộ flashcard tự động tạo từ tài liệu giúp mình nhớ bài cực kỳ lâu."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f59e0b;">TH</div>
                                            <div class="author-info">
                                                <div class="author-name">Lê Thu Hương</div>
                                                <div class="author-role">Học sinh lớp 11</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 3 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Tính năng luyện đề trắc nghiệm AI rất sát với
                                                thực tế. Mình đã đạt kết quả cao trong kỳ thi giữa kỳ nhờ ôn luyện tại
                                                đây."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #8b5cf6;">QH</div>
                                            <div class="author-info">
                                                <div class="author-name">Phạm Quang Huy</div>
                                                <div class="author-role">Sinh viên CNTT</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 4 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Các box học tập rất hay và trực quan. Giao
                                                diện thân thiện tiếp thêm động lực học mỗi ngày cho mình và bạn bè."
                                            </div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #f43f5e;">NL</div>
                                            <div class="author-info">
                                                <div class="author-name">Võ Ngọc Linh</div>
                                                <div class="author-role">Học sinh lớp 10</div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Card 5 -->
                                    <div class="testimonial-card">
                                        <div class="testimonial-quote-mark">”</div>
                                        <div class="testimonial-content">
                                            <div class="testimonial-stars">★ ★ ★ ★ ★</div>
                                            <div class="testimonial-text">"Quy trình kiểm duyệt giúp kho học liệu luôn
                                                giữ tiêu chuẩn cao. Công cụ AI hỗ trợ tạo câu hỏi giúp tôi tiết kiệm 80%
                                                thời gian."</div>
                                        </div>
                                        <div class="testimonial-author">
                                            <div class="author-avatar" style="background: #059669;">MT</div>
                                            <div class="author-info">
                                                <div class="author-name">Trần Minh Tuấn</div>
                                                <div class="author-role">Giảng viên Toán</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- ========================================================== -->
                        <!-- BANNER CỘNG ĐỒNG HIPZI (CHÍNH GIỮA FULL-WIDTH TOÀN TRANG)  -->
                        <!-- ========================================================== -->
                        <div class="fade-up-element"
                            style="max-width:1320px; width:100%; margin:4.5rem auto 2.5rem auto; padding:0 1.5rem;">
                            <div class="community-engagement-banner"
                                style="background:#ffffff; border-radius:1.5rem; border:1px solid #e2e8f0; box-shadow:0 10px 30px rgba(0, 0, 0, 0.03); padding:2.5rem; display:flex; flex-direction:column; gap:1.75rem; position:relative; overflow:hidden;">

                                <!-- Dải lấp lánh trang trí góc phải -->
                                <div
                                    style="position:absolute; top:0; right:0; width:350px; height:350px; background:radial-gradient(circle, rgba(5, 150, 105, 0.05) 0%, transparent 70%); pointer-events:none;">
                                </div>

                                <div style="display:flex; flex-direction:column; gap:1.25rem; z-index:1;">
                                    <!-- Badge Hỗ trợ / Cộng đồng -->
                                    <div>
                                        <span
                                            style="display:inline-flex; align-items:center; gap:0.4rem; background:#ecfdf5; color:#059669; font-weight:800; font-size:0.75rem; padding:0.4rem 1rem; border-radius:2rem; letter-spacing:0.5px; text-transform:uppercase;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                stroke="currentColor" stroke-width="2.5">
                                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                            </svg>
                                            Hỗ trợ học tập 24/7
                                        </span>
                                    </div>

                                    <!-- Hàng Flex chính chia 2 cột -->
                                    <div
                                        style="display:flex; flex-direction:row; justify-content:space-between; align-items:center; gap:2.5rem; flex-wrap:wrap;">

                                        <!-- Cột Trái: Tiêu đề & Lời kêu gọi -->
                                        <div
                                            style="flex:1; min-width:320px; display:flex; flex-direction:column; gap:1rem; text-align:left;">
                                            <h3
                                                style="font-weight:800; font-size:2.15rem; color:#0f172a; line-height:1.25; margin:0; letter-spacing:-0.5px;">
                                                Tham Gia <span
                                                    style="background:linear-gradient(135deg, rgb(4, 120, 87) 0%, rgb(16, 185, 129) 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; font-style:italic;">Cộng
                                                    Đồng HIPZI?</span>
                                            </h3>
                                            <p
                                                style="font-size:0.95rem; color:#475569; line-height:1.55; margin:0; max-width:550px;">
                                                Đừng ngần ngại kết nối với đội ngũ giảng viên và cộng đồng học viên để
                                                cùng trao đổi kiến thức, định hướng lộ trình học tập phù hợp và hiệu quả
                                                nhất với bản thân.
                                            </p>

                                            <!-- Hàng Nút Hành động CTA -->
                                            <div
                                                style="display:flex; align-items:center; gap:0.85rem; margin-top:0.5rem; flex-wrap:wrap;">
                                                <a href="https://zalo.me/g/hipzi2024" target="_blank"
                                                    style="background:#059669; color:#ffffff; font-weight:700; font-size:0.85rem; padding:0.85rem 1.75rem; border-radius:0.75rem; text-decoration:none; display:inline-flex; align-items:center; gap:0.5rem; box-shadow:0 4px 12px rgba(5, 150, 105, 0.25); transition:all 0.2s ease; letter-spacing:0.5px;"
                                                    onmouseover="this.style.background='#047857'; this.style.transform='translateY(-2px)';"
                                                    onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.5">
                                                        <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
                                                    </svg>
                                                    THAM GIA CỘNG ĐỒNG
                                                </a>
                                            </div>
                                        </div>

                                        <!-- Cột Phải: Khung Highlight Thông số bo tròn màu xám nhạt -->
                                        <div
                                            style="background:#f8fafc; border-radius:1.25rem; padding:1.5rem; border:1px solid #f1f5f9; display:flex; flex-direction:column; gap:1.25rem; min-width:260px;">

                                            <!-- Thông số 1 -->
                                            <div style="display:flex; align-items:center; gap:1rem;">
                                                <div
                                                    style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#2563eb; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.2">
                                                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                                                        <circle cx="9" cy="7" r="4" />
                                                        <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                                                        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                                                    </svg>
                                                </div>
                                                <div style="display:flex; flex-direction:column; text-align:left;">
                                                    <span
                                                        style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">GIẢNG
                                                        VIÊN ONLINE</span>
                                                    <span style="font-size:1.05rem; font-weight:800; color:#0f172a;">Hơn
                                                        50+ Mentor</span>
                                                </div>
                                            </div>

                                            <div style="height:1px; background:#f1f5f9;"></div>

                                            <!-- Thông số 2 -->
                                            <div style="display:flex; align-items:center; gap:1rem;">
                                                <div
                                                    style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#10b981; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2.2">
                                                        <circle cx="12" cy="12" r="10" />
                                                        <line x1="2" y1="12" x2="22" y2="12" />
                                                        <path
                                                            d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
                                                    </svg>
                                                </div>
                                                <div style="display:flex; flex-direction:column; text-align:left;">
                                                    <span
                                                        style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">CỘNG
                                                        ĐỒNG HỌC VIÊN</span>
                                                    <span
                                                        style="font-size:1.05rem; font-weight:800; color:#0f172a;">2000+
                                                        Thành viên</span>
                                                </div>
                                            </div>

                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>

                    </section>

                    <!-- PHẦN LIÊN HỆ VỚI CHÚNG TÔI / CONTACT SECTION -->
                    <section class="contact-section" id="contact">
                        <div class="contact-header">
                            <h2 class="section-title scroll-letter-title">Liên hệ với chúng tôi</h2>
                            <p class="typewriter-text">Bạn có câu hỏi hoặc cần hỗ trợ? Hãy gửi tin nhắn ngay cho đội ngũ
                                HIPZI để được giải đáp sớm nhất.</p>
                        </div>

                        <div class="contact-container">
                            <!-- Left Column: Contact Form -->
                            <div class="contact-left-col">
                                <div class="contact-form-card">
                                    <form id="contactForm" action="${pageContext.request.contextPath}/contact"
                                        method="POST">
                                        <div class="contact-form-grid">
                                            <!-- Name -->
                                            <div class="contact-form-group">
                                                <label class="contact-label">Họ và tên</label>
                                                <div class="contact-input-wrapper">
                                                    <span class="contact-input-icon">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                            <circle cx="12" cy="7" r="4"></circle>
                                                        </svg>
                                                    </span>
                                                    <input type="text" name="name" class="contact-input"
                                                        placeholder="Nhập họ và tên của bạn" required />
                                                </div>
                                            </div>

                                            <!-- Email -->
                                            <div class="contact-form-group">
                                                <label class="contact-label">Email</label>
                                                <div class="contact-input-wrapper">
                                                    <span class="contact-input-icon">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path
                                                                d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z">
                                                            </path>
                                                            <polyline points="22,6 12,13 2,6"></polyline>
                                                        </svg>
                                                    </span>
                                                    <input type="email" name="email" class="contact-input"
                                                        placeholder="ví dụ: email@gmail.com" required />
                                                </div>
                                            </div>

                                            <!-- Phone -->
                                            <div class="contact-form-group">
                                                <label class="contact-label">Số điện thoại</label>
                                                <div class="contact-input-wrapper">
                                                    <span class="contact-input-icon">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <rect x="5" y="2" width="14" height="20" rx="2" ry="2">
                                                            </rect>
                                                            <line x1="12" y1="18" x2="12.01" y2="18"></line>
                                                        </svg>
                                                    </span>
                                                    <input type="tel" name="phone" class="contact-input"
                                                        placeholder="Nhập số điện thoại" required />
                                                </div>
                                            </div>

                                            <!-- Textarea -->
                                            <div class="contact-form-group">
                                                <label class="contact-label">Lời nhắn</label>
                                                <textarea name="message" class="contact-textarea"
                                                    placeholder="Nội dung lời nhắn của bạn..." required></textarea>
                                            </div>

                                            <!-- Submit Button -->
                                            <div class="contact-submit-wrapper">
                                                <button type="submit" class="btn-contact">Gửi lời nhắn</button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Right Column: Donation QR Card -->
                            <div class="contact-right-col">
                                <div class="contact-support-card">
                                    <div class="support-header">
                                        <h3>Ủng hộ phát triển HIPZI ❤️</h3>
                                        <p>Nếu bạn yêu thích và muốn đồng hành cùng HIPZI, bạn có thể ủng hộ (donate)
                                            qua tài khoản dưới đây. Sự đóng góp của bạn là động lực to lớn giúp đội ngũ
                                            duy trì và phát triển nền tảng!</p>
                                    </div>
                                    <div class="support-qr-wrapper">
                                        <img src="${pageContext.request.contextPath}/assets/images/qr_payment.png"
                                            alt="Mã QR TPBank NGUYEN NGOC THACH">
                                    </div>
                                    <div class="support-payment-details">
                                        <div class="payment-detail-item">
                                            <span class="detail-label">Ngân hàng</span>
                                            <span class="detail-value">TPBank</span>
                                        </div>
                                        <div class="payment-detail-item">
                                            <span class="detail-label">Chủ tài khoản</span>
                                            <span class="detail-value uppercase">NGUYEN NGOC THACH</span>
                                        </div>
                                        <div class="payment-detail-item">
                                            <span class="detail-label">Số tài khoản</span>
                                            <span class="detail-value highlighted">8662 5062 006</span>
                                        </div>
                                    </div>
                                    <div class="support-footer">
                                        <p class="thank-you-text">💝 Xin chân thành cảm ơn tấm lòng và sự ủng hộ của
                                            bạn!</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- CHÂN TRANG / FOOTER -->
                    <footer class="footer">
                        <div class="footer-card">
                            <!-- Top Content Grid -->
                            <div class="footer-top-grid">
                                <!-- Brand Info & Socials -->
                                <div class="footer-brand-col">
                                    <a href="${pageContext.request.contextPath}/index" class="footer-logo">
                                        <img src="${pageContext.request.contextPath}/assets/images/favicon.png"
                                            alt="HIPZI Logo">
                                        <span>HIPZI</span>
                                    </a>
                                    <p class="footer-desc">Nền tảng giáo dục thông minh kết hợp tài liệu học tập, luyện
                                        tập tương tác và công nghệ AI nhằm tối ưu hóa hành trình tri thức.</p>

                                    <!-- Social Links -->
                                    <div class="footer-socials">
                                        <a href="#" class="social-btn" title="Facebook">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"
                                                aria-hidden="true">
                                                <path
                                                    d="M14 8.7V6.9c0-.86.2-1.3 1.38-1.3H17V2.17C16.21 2.06 15.44 2 14.67 2 11.9 2 10 3.69 10 6.79V8.7H7v3.82h3V22h4v-9.48h3.22l.5-3.82H14Z">
                                                </path>
                                            </svg>
                                        </a>
                                        <a href="#" class="social-btn" title="TikTok">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"
                                                aria-hidden="true">
                                                <path
                                                    d="M16.36 2c.28 2.39 1.62 3.82 3.86 3.97v3.33a7.23 7.23 0 0 1-3.8-1.14v6.8c0 4.37-3.32 6.89-6.58 6.89-3.61 0-6.06-2.73-6.06-5.96 0-3.78 2.96-6.1 6.78-5.94v3.48c-1.72-.25-3.17.74-3.17 2.43 0 1.38 1.08 2.38 2.45 2.38 1.53 0 2.68-.91 2.68-3.06V2h3.84Z">
                                                </path>
                                            </svg>
                                        </a>
                                        <a href="#" class="social-btn" title="YouTube">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"
                                                aria-hidden="true">
                                                <path
                                                    d="M21.58 7.18a3.02 3.02 0 0 0-2.12-2.12C17.58 4.56 12 4.56 12 4.56s-5.58 0-7.46.5a3.02 3.02 0 0 0-2.12 2.12A31.5 31.5 0 0 0 1.92 12c0 1.66.16 3.24.5 4.82a3.02 3.02 0 0 0 2.12 2.12c1.88.5 7.46.5 7.46.5s5.58 0 7.46-.5a3.02 3.02 0 0 0 2.12-2.12c.34-1.58.5-3.16.5-4.82s-.16-3.24-.5-4.82ZM10.02 15.55v-7.1L16.2 12l-6.18 3.55Z">
                                                </path>
                                            </svg>
                                        </a>
                                    </div>
                                </div>

                                <!-- Navigation Columns Wrapper -->
                                <div class="footer-links-wrapper">
                                    <!-- Column 1 -->
                                    <div class="footer-links-col footer-student-col">
                                        <h4>Học viên</h4>
                                        <ul>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/material-repository">
                                                    <span class="footer-student-icon" aria-hidden="true">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2.1"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path
                                                                d="M4 19.5V5a2 2 0 0 1 2-2h11a3 3 0 0 1 3 3v13a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2Z">
                                                            </path>
                                                            <path d="M8 7h7"></path>
                                                            <path d="M8 11h5"></path>
                                                        </svg>
                                                    </span>
                                                    <span>Tìm kiếm tài liệu</span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/practice">
                                                    <span class="footer-student-icon" aria-hidden="true">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2.1"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path d="M9 11h6"></path>
                                                            <path d="M9 15h3"></path>
                                                            <path
                                                                d="M8 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-2">
                                                            </path>
                                                            <rect x="8" y="2" width="8" height="4" rx="1"></rect>
                                                        </svg>
                                                    </span>
                                                    <span>Luyện tập Trắc nghiệm</span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/practice">
                                                    <span class="footer-student-icon" aria-hidden="true">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2.1"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <rect x="3" y="6" width="18" height="12" rx="2"></rect>
                                                            <path d="M7 10h5"></path>
                                                            <path d="M7 14h3"></path>
                                                            <path d="M15.5 12h2"></path>
                                                        </svg>
                                                    </span>
                                                    <span>Bộ thẻ Flashcard</span>
                                                </a>
                                            </li>
                                        </ul>
                                    </div>

                                    <!-- Column 2 -->
                                    <div class="footer-links-col footer-service-col footer-teacher-col">
                                        <h4>Giảng viên</h4>
                                        <ul>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/register">
                                                    <span class="footer-service-icon" aria-hidden="true">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2.1"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
                                                            <circle cx="9" cy="7" r="4"></circle>
                                                            <path d="M19 8v6"></path>
                                                            <path d="M22 11h-6"></path>
                                                        </svg>
                                                    </span>
                                                    <span>Đăng ký giảng dạy</span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/login">
                                                    <span class="footer-service-icon" aria-hidden="true">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2.1"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path
                                                                d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z">
                                                            </path>
                                                            <path d="M14 2v6h6"></path>
                                                            <path d="M9 15h6"></path>
                                                            <path d="M9 18h4"></path>
                                                        </svg>
                                                    </span>
                                                    <span>Quy định tải lên</span>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/login">
                                                    <span class="footer-service-icon" aria-hidden="true">
                                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                            stroke="currentColor" stroke-width="2.1"
                                                            stroke-linecap="round" stroke-linejoin="round">
                                                            <path
                                                                d="M12 3l1.6 4.7L18 9l-4.4 1.3L12 15l-1.6-4.7L6 9l4.4-1.3Z">
                                                            </path>
                                                            <path
                                                                d="M19 14l.8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8Z">
                                                            </path>
                                                            <path
                                                                d="M5 14l.8 2.2L8 17l-2.2.8L5 20l-.8-2.2L2 17l2.2-.8Z">
                                                            </path>
                                                        </svg>
                                                    </span>
                                                    <span>Công cụ AI</span>
                                                </a>
                                            </li>
                                        </ul>
                                    </div>

                                    <!-- Column 3 -->
                                    <div class="footer-links-col footer-dev-col">
                                        <h4>Đội ngũ phát triển</h4>
                                        <ul>
                                            <li>
                                                <div>
                                                    <span class="footer-dev-role">Admin</span>
                                                    <strong>Nguyễn Ngọc Thạch</strong>
                                                    <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 4px;">
                                                        <a class="footer-dev-email"
                                                            href="mailto:nguyenngocthach531@gmail.com">
                                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                                                stroke="currentColor" stroke-width="2.1"
                                                                stroke-linecap="round" stroke-linejoin="round"
                                                                aria-hidden="true">
                                                                <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                                                                <path d="m3 7 9 6 9-6"></path>
                                                            </svg>
                                                            <span>nguyenngocthach531@gmail.com</span>
                                                        </a>
                                                        <a class="footer-dev-email" href="tel:0911265346">
                                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                                                <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.35 1.9.65 2.8a2 2 0 0 1-.45 2.11L8.03 9.91a16 16 0 0 0 6.06 6.06l1.28-1.28a2 2 0 0 1 2.11-.45c.9.3 1.84.52 2.8.65A2 2 0 0 1 22 16.92Z"></path>
                                                            </svg>
                                                            <span>0911 265 346</span>
                                                        </a>
                                                    </div>
                                                </div>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>

                            <!-- Footer Contact & Map -->
                            <div class="footer-contact-map" id="footer-contact">
                                <div class="footer-map-panel">
                                    <iframe title="Bản đồ HIPZI"
                                        src="https://maps.google.com/maps?hl=vi&ll=15.966996,108.252610&z=15&output=embed"
                                        loading="lazy" referrerpolicy="no-referrer-when-downgrade">
                                    </iframe>
                                </div>

                                <div class="footer-contact-info">
                                    <h3>Thông tin liên hệ HIPZI</h3>
                                    <ul class="footer-contact-list">
                                        <li>
                                            <span class="footer-contact-icon" aria-hidden="true">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                    stroke-linejoin="round">
                                                    <path d="M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0Z"></path>
                                                    <circle cx="12" cy="10" r="3"></circle>
                                                </svg>
                                            </span>
                                            <div>
                                                <strong>Địa chỉ</strong>
                                                <span>Khu đô thị FPT, Đà Nẵng</span>
                                            </div>
                                        </li>
                                        <li>
                                            <span class="footer-contact-icon" aria-hidden="true">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                    stroke-linejoin="round">
                                                    <rect x="3" y="5" width="18" height="14" rx="2"></rect>
                                                    <path d="m3 7 9 6 9-6"></path>
                                                </svg>
                                            </span>
                                            <div>
                                                <strong>Email</strong>
                                                <a href="mailto:support@hipzi.vn">support@hipzi.vn</a>
                                            </div>
                                        </li>
                                        <li>
                                            <span class="footer-contact-icon" aria-hidden="true">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                    stroke-linejoin="round">
                                                    <path
                                                        d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.12 4.18 2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.35 1.9.65 2.8a2 2 0 0 1-.45 2.11L8.03 9.91a16 16 0 0 0 6.06 6.06l1.28-1.28a2 2 0 0 1 2.11-.45c.9.3 1.84.52 2.8.65A2 2 0 0 1 22 16.92Z">
                                                    </path>
                                                </svg>
                                            </span>
                                            <div>
                                                <strong>Hotline</strong>
                                                <a href="tel:0911256346">0911 256 346</a>
                                            </div>
                                        </li>
                                        <li>
                                            <span class="footer-contact-icon" aria-hidden="true">
                                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2.2" stroke-linecap="round"
                                                    stroke-linejoin="round">
                                                    <circle cx="12" cy="12" r="9"></circle>
                                                    <path d="M12 7v5l3 2"></path>
                                                </svg>
                                            </span>
                                            <div>
                                                <strong>Thời gian hỗ trợ</strong>
                                                <span>08:00 - 22:00</span>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </div>

                            <!-- Bottom Legal Inline Bar -->
                            <div class="footer-bottom-bar">
                                <div class="footer-copyright">
                                    &copy; 2026 HIPZI Platform. Bản quyền được bảo hộ.
                                </div>
                                <div class="footer-legal-links">
                                    <a href="#">Chính Sách Bảo Mật</a>
                                    <a href="#">Điều Khoản Dịch Vụ</a>
                                    <a href="#">Cài Đặt Cookie</a>
                                </div>
                            </div>
                        </div>
                    </footer>

                    <%@ include file="/WEB-INF/fragments/hipzi-chat-widget.jspf" %>

                    <script src="${pageContext.request.contextPath}/assets/js/navbar.js?v=3"></script>
                    <script src="${pageContext.request.contextPath}/assets/js/hipzi-chat-widget.js?v=3"></script>
                    <!-- Hieu ung cuon muot va cham Lenis JS -->
                    <script src="https://unpkg.com/lenis@1.1.13/dist/lenis.min.js"></script>
                    <script>
                        document.addEventListener('DOMContentLoaded', () => {
                            // Khoi tao Lenis voi cau hinh cuon muot ma va phan hoi nhanh hon
                            const lenis = new Lenis({
                                duration: 1.2,        // Thời gian thực hiện cuộn (giây) - giảm để cuộn nhanh hơn
                                lerp: 0.1,            // Tăng lerp lên 0.1 để phản hồi nhanh và nhạy hơn
                                wheelMultiplier: 1.0, // Đặt hệ số cuộn về 1.0 (mặc định) để giữ nguyên tốc độ lăn chuẩn
                                syncTouch: true       // Đồng bộ hiệu ứng mượt trên cả thiết bị cảm ứng
                            });

                            // Vòng lặp animation frame bắt buộc của Lenis
                            function raf(time) {
                                lenis.raf(time);
                                requestAnimationFrame(raf);
                            }
                            requestAnimationFrame(raf);

                            // Hiệu ứng Fade Up cho Banner Cộng đồng
                            const fadeUpElements = document.querySelectorAll('.fade-up-element');
                            if (fadeUpElements.length > 0) {
                                const fadeObserver = new IntersectionObserver((entries) => {
                                    entries.forEach(entry => {
                                        if (entry.isIntersecting) {
                                            entry.target.classList.add('is-visible');
                                            fadeObserver.unobserve(entry.target);
                                        }
                                    });
                                }, { threshold: 0.25 });

                                fadeUpElements.forEach(el => fadeObserver.observe(el));
                            }

                            // Hiệu ứng Thống kê (Stats Counter)
                            const statsSection = document.querySelector('.stats-container.reveal-up');
                            if (statsSection) {
                                const statsObserver = new IntersectionObserver((entries) => {
                                    entries.forEach(entry => {
                                        if (entry.isIntersecting) {
                                            // Kích hoạt hiệu ứng nổi lên
                                            entry.target.classList.add('is-visible');

                                            // Kích hoạt hiệu ứng đếm số chạy từ 0
                                            const counters = document.querySelectorAll('.stat-counter');
                                            counters.forEach(counter => {
                                                const targetStr = counter.getAttribute('data-target');
                                                const target = parseFloat(targetStr);
                                                const isFloat = targetStr.includes('.');
                                                const duration = 2000; // Thời gian chạy (2 giây)
                                                const increment = target / (duration / 16); // Mỗi frame ~16ms

                                                let current = 0;
                                                const updateCounter = () => {
                                                    current += increment;
                                                    if (current < target) {
                                                        if (isFloat) {
                                                            counter.innerText = current.toFixed(1).replace('.', ',');
                                                        } else {
                                                            counter.innerText = Math.ceil(current).toLocaleString('vi-VN');
                                                        }
                                                        requestAnimationFrame(updateCounter);
                                                    } else {
                                                        if (isFloat) {
                                                            counter.innerText = target.toFixed(1).replace('.', ',');
                                                        } else {
                                                            counter.innerText = target.toLocaleString('vi-VN');
                                                        }
                                                    }
                                                };
                                                updateCounter();
                                            });

                                            statsObserver.unobserve(entry.target);
                                        }
                                    });
                                }, { threshold: 0.5 });

                                statsObserver.observe(statsSection);
                            }

                            // Xử lý gửi Form Liên hệ trang chủ qua AJAX
                            const contactForm = document.getElementById('contactForm');
                            if (contactForm) {
                                contactForm.addEventListener('submit', function (e) {
                                    e.preventDefault();

                                    const submitBtn = contactForm.querySelector('.btn-contact');
                                    const originalText = submitBtn.textContent;
                                    submitBtn.disabled = true;
                                    submitBtn.textContent = 'Đang gửi liên hệ...';

                                    const formData = new URLSearchParams();
                                    formData.append('name', contactForm.querySelector('[name="name"]').value);
                                    formData.append('email', contactForm.querySelector('[name="email"]').value);
                                    formData.append('phone', contactForm.querySelector('[name="phone"]').value);
                                    formData.append('message', contactForm.querySelector('[name="message"]').value);

                                    fetch(contactForm.action, {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded'
                                        },
                                        body: formData.toString()
                                    })
                                        .then(response => {
                                            if (response.ok) {
                                                return response.json();
                                            } else {
                                                return response.json().then(err => { throw new Error(err.error || 'Có lỗi xảy ra!'); });
                                            }
                                        })
                                        .then(data => {
                                            alert(data.message || 'Gửi liên hệ thành công!');
                                            contactForm.reset();
                                        })
                                        .catch(error => {
                                            alert('Lỗi: ' + error.message);
                                        })
                                        .finally(() => {
                                            submitBtn.disabled = false;
                                            submitBtn.textContent = originalText;
                                        });
                                });
                            }
                        });
                    </script>
            </body>

            </html>

