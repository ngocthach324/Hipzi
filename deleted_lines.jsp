        String teachingRegistrationStatus = teacherApplication != null ? teacherApplication.getStatus() : null;
        String teachingRegistrationStatusLabel = "─Éang chß╗¥ duyß╗çt";
        if ("approved".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "─É├ú duyß╗çt";
        } else if ("rejected".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Kh├┤ng ─æ╞░ß╗úc duyß╗çt";
        } else if ("needs_more_info".equals(teachingRegistrationStatus)) {
            teachingRegistrationStatusLabel = "Cß║ºn bß╗ò sung th├┤ng tin";
        }
        boolean registrationNeedsAttention = !teachingRegistrationSubmitted
                || "rejected".equals(teachingRegistrationStatus)
                || "needs_more_info".equals(teachingRegistrationStatus);
        String initialTeacherTab = request.getParameter("tab");
        if (initialTeacherTab == null || initialTeacherTab.trim().isEmpty()) {
            initialTeacherTab = "tab-teaching-registration";
        } else {
            initialTeacherTab = initialTeacherTab.trim();
            if (initialTeacherTab.equals("materials") || initialTeacherTab.equals("practice") ||
                initialTeacherTab.equals("tab-materials") || initialTeacherTab.equals("tab-practice")) {
                initialTeacherTab = "tab-upload-material";
            } else if (!initialTeacherTab.startsWith("tab-")) {
                initialTeacherTab = "tab-" + initialTeacherTab;
            }
            if (!initialTeacherTab.equals("tab-teaching-registration") &&
                !initialTeacherTab.equals("tab-class-registration") &&
                !initialTeacherTab.equals("tab-profile") &&
                !initialTeacherTab.equals("tab-edit") &&
                !initialTeacherTab.equals("tab-security") &&
                !initialTeacherTab.equals("tab-upload-material") &&
                !initialTeacherTab.equals("tab-support") &&
                !initialTeacherTab.equals("tab-balance-stats") &&
                !initialTeacherTab.equals("tab-transaction-history")) {
                initialTeacherTab = "tab-teaching-registration";
            }
        }
    %>

    <%@ include file="/WEB-INF/fragments/profile-role-label.jspf" %>



    <!-- ===== D├ÇN TRANG CH├ìNH THEO Bß╗É Cß╗ñC PREMIUM ─Éß╗ÆNG Bß╗ÿ DONEZO ===== -->
    <div class="app-dashboard-container">
        
        <!-- K├èNH SIDEBAR TR├üI (LEFT PANE) -->
        <aside class="dashboard-sidebar">
            <div class="sidebar-brand-horizontal">
                <a href="${pageContext.request.contextPath}/index" class="brand-avatar-box" title="Trang chß╗º">
                    <img src="${pageContext.request.contextPath}/assets/images/favicon.png" alt="Hipzi Logo">
                </a>
                <div class="brand-text-col">
                    <span class="brand-title">Hipzi</span>
                    <span class="brand-subtitle">Platform</span>
                </div>
                <button type="button" class="sidebar-toggle-btn" title="Thu gß╗ìn / Mß╗ƒ rß╗Öng" onclick="toggleSidebar()">
                    <svg class="icon-collapse" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M16 15l-3-3 3-3"/></svg>
                    <svg class="icon-expand" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="display: none;"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/><path d="M13 9l3 3-3 3"/></svg>
                </button>
            </div>
            
            <div class="sidebar-section-label">Tß╗òng quan</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-profile" class="<%= ("tab-profile".equals(initialTeacherTab) || "tab-edit".equals(initialTeacherTab)) ? "active" : "" %>" onclick="switchTab('tab-profile')" title="Hß╗ô s╞í c├í nh├ón">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="3" width="7" height="9" rx="1"/><rect x="14" y="3" width="7" height="5" rx="1"/><rect x="14" y="12" width="7" height="9" rx="1"/><rect x="3" y="16" width="7" height="5" rx="1"/></svg>
                        <span>Hß╗ô s╞í c├í nh├ón</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-security" class="<%= "tab-security".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-security')" title="Bß║úo mß║¡t">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        <span>Bß║úo mß║¡t</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-support" class="<%= "tab-support".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-support')" title="Hß╗ù trß╗ú giß║úng dß║íy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                        <span>Hß╗ù trß╗ú giß║úng dß║íy</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">Quß║ún l├╜ giß║úng dß║íy</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-teaching-registration" class="<%= "tab-teaching-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-teaching-registration')" title="─É─âng k├¡ giß║úng dß║íy">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                        <span>─É─âng k├¡ giß║úng dß║íy</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-class-registration" class="<%= "tab-class-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-class-registration')" title="─É─âng k├¡ lß╗¢p hß╗ìc">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                        <span>─É─âng k├¡ lß╗¢p hß╗ìc</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-course-registration" class="<%= "tab-course-registration".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-course-registration')" title="─É─âng kh├│a hß╗ìc">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg>
                        <span>─É─âng kh├│a hß╗ìc</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-upload-material" class="<%= "tab-upload-material".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-upload-material')" title="─É─âng tß║úi t├ái liß╗çu">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                        <span>─É─âng tß║úi t├ái liß╗çu</span>
                    </a>
                </li>
            </ul>

            <div class="sidebar-section-label">V├¡ tiß╗ün</div>
            <ul class="sidebar-menu">
                <li>
                    <a id="nav-tab-balance-stats" class="<%= "tab-balance-stats".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-balance-stats')" title="Thß╗æng k├¬ sß╗æ d╞░">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-3a2 2 0 0 0 0-4z"/><circle cx="18" cy="12" r="1"/></svg>
                        <span>Thß╗æng k├¬ sß╗æ d╞░</span>
                    </a>
                </li>
                <li>
                    <a id="nav-tab-transaction-history" class="<%= "tab-transaction-history".equals(initialTeacherTab) ? "active" : "" %>" onclick="switchTab('tab-transaction-history')" title="Lß╗ïch sß╗¡ giao dß╗ïch">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg>
                        <span>Lß╗ïch sß╗¡ giao dß╗ïch</span>
                    </a>
                </li>
            </ul>

        </aside>

        <!-- K├èNH PHß║óI CH├ìNH -->
        <div class="dashboard-main-section">
            
            <!-- TOP BAR ─Éß╗ÆNG Bß╗ÿ DONEZO -->
            <div class="dashboard-top-bar">
                <div class="top-bar-search-wrapper">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="text" placeholder="T├¼m kiß║┐m t├íc vß╗Ñ...">

                </div>

                <div class="top-bar-right">
                    <!-- Toggle giao diß╗çn S├íng / Tß╗æi -->
                    <div class="nav-bell-trigger" title="Chuyß╗ân chß║┐ ─æß╗Ö s├íng/tß╗æi" onclick="alert('Chß╗⌐c n─âng chuyß╗ân ─æß╗òi giao diß╗çn s├íng/tß╗æi ─æang ─æ╞░ß╗úc ph├ít triß╗ân.')">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
                    </div>

                    <!-- Notification dropdown fragment -->
                    <%@ include file="/WEB-INF/fragments/notification-bell.jspf" %>

                    <!-- N├║t ─É─âng xuß║Ñt -->
                    <a href="${pageContext.request.contextPath}/logout" class="nav-bell-trigger" title="─É─âng xuß║Ñt" style="text-decoration: none;">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                    </a>

                    <!-- User info card -->
                    <div class="top-bar-user-card" onclick="switchTab('tab-profile')">
                        <% if (user != null && user.getAvatarUrl() != null && !user.getAvatarUrl().isEmpty()) { %>
                            <img src="<%= user.getAvatarUrl() %>" class="top-bar-avatar" alt="Avatar">
                        <% } else { %>
                            <div class="top-bar-avatar-placeholder"><%= initials %></div>
                        <% } %>
                        <div class="top-bar-user-info">
                            <span class="top-bar-user-name"><%= user != null ? user.getDisplayName() : "Giß║úng vi├¬n HIPZI" %></span>
                            <span class="top-bar-user-email"><%= user != null ? user.getEmail() : "info@hipzi.vn" %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- CHß╗¿A WORKSPACE TAB PANES -->
            <main class="dashboard-content-wrapper">

            <!-- Banner dß║úi m├áu trang tr├¡ ph├¡a tr├¬n c├╣ng (Top Accent Strip) -->


            <!-- Th├┤ng b├ío nhß║»c nhß╗ƒ Onboarding (Nß║┐u ─æ─âng k├╜ qua Google m├á ch╞░a chß╗ìn role) -->
            <% if (user != null && !user.isOnboardingCompleted()) { %>
            <div class="onboarding-banner" style="margin-top: -0.5rem;">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#92400e" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                <p>Hß╗ô s╞í cß╗ºa bß║ín ─æang chß╗¥ ho├án tß║Ñt thiß║┐t lß║¡p vai tr├▓ hß╗ìc vi├¬n sß╗¡ dß╗Ñng nß╗ün tß║úng.</p>
                <a href="${pageContext.request.contextPath}/onboarding">Ho├án tß║Ñt ngay</a>
            </div>
            <% } %>

            <!-- ========================================== -->
            <!-- TAB 1: Hß╗Æ S╞á C├ü NH├éN Tß╗öNG QUAN             -->
            <!-- ========================================== -->
            <section id="tab-teaching-registration" class="tab-pane <%= "tab-teaching-registration".equals(initialTeacherTab) ? "active-pane" : "" %>">
                <div class="tab-pane-header">
                    <div class="tab-pane-header-left">
                        <h1>─É─âng k├¡ giß║úng dß║íy</h1>
                        <p>Ho├án thiß╗çn hß╗ô s╞í n─âng lß╗▒c giß║úng dß║íy ─æß╗â ─æ╞░ß╗úc x├⌐t duyß╗çt hß╗ìc liß╗çu v├á giß║úng dß║íy.</p>
                    </div>
                    <div class="tab-pane-header-right">
                        <div class="date-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                            <span><%= currentDateDisplay %></span>
                        </div>
                    </div>
                </div>

                <div class="premium-card">
                        <% if (teachingRegistrationSubmitted) { %>
                            <div class="teacher-application-status">
                                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                <div>
                                    <div style="font-weight:800; margin-bottom:0.25rem;">Hß╗ô s╞í ─æ─âng k├¡ giß║úng dß║íy ─æ├ú ─æ╞░ß╗úc gß╗¡i.</div>
                                    <div style="font-size:0.82rem; font-weight:800; margin-bottom:0.35rem; text-transform:uppercase; letter-spacing:0.4px;">Trß║íng th├íi: <%= teachingRegistrationStatusLabel %></div>
                                    <div style="font-size:0.9rem; line-height:1.55;">
                                        <% if (teacherApplication != null && teacherApplication.getReviewNote() != null && !teacherApplication.getReviewNote().trim().isEmpty()) { %>
                                            <%= teacherApplication.getReviewNote() %>
                                        <% } else { %>
                                            ─Éß╗Öi ng┼⌐ quß║ún trß╗ï sß║╜ kiß╗âm tra minh chß╗⌐ng v├á phß║ún hß╗ôi qua email. Bß║ín vß║½n c├│ thß╗â gß╗¡i lß║íi nß║┐u cß║ºn cß║¡p nhß║¡t th├┤ng tin.
                                        <% } %>
                                    </div>
                                </div>
                            </div>
                        <% } %>

                        <form action="${pageContext.request.contextPath}/teacher-profile" method="POST" enctype="multipart/form-data" class="form-edit-layout" style="padding:0;" onsubmit="return validateTeachingSubjects()">
                            <input type="hidden" name="action" value="submitTeachingRegistration">

                            <div class="section-data-card">
                                <div class="card-header-layout">
                                    <div class="card-header-title">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 3l8 4.5-8 4.5-8-4.5L12 3z"/><path d="M4 12l8 4.5 8-4.5"/><path d="M4 16.5l8 4.5 8-4.5"/></svg>
                                        <span>Ph├ón loß║íi giß║úng vi├¬n</span>
                                    </div>
                                    <span style="font-size:0.8rem; font-weight:700; color:var(--primary); background:var(--primary-light); padding:0.2rem 0.75rem; border-radius:1rem;">Bß║»t buß╗Öc</span>
                                </div>

                                <div style="padding:1.5rem;">
                                    <p class="teacher-type-helper-text">Vui l├▓ng chß╗ìn nh├│m giß║úng vi├¬n hiß╗çn tß║íi cß╗ºa bß║ín tr╞░ß╗¢c khi ─æiß╗ün th├┤ng tin.</p>
                                    <div class="teacher-type-grid">
                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="student_tutor" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nh├│m 1</span>
                                                <h3 class="teacher-type-title">Gia s╞░ sinh vi├¬n</h3>
                                                <p class="teacher-type-description">Ph├╣ hß╗úp vß╗¢i hß╗ìc vi├¬n cß║ºn ng╞░ß╗¥i h╞░ß╗¢ng dß║½n gß║ºn g┼⌐i, hß╗ù trß╗ú b├ái tß║¡p, ├┤n tß║¡p kiß║┐n thß╗⌐c nß╗ün tß║úng hoß║╖c hß╗ìc theo nh├│m nhß╗Å.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Sinh vi├¬n S╞░ phß║ím To├ín</li>
                                                    <li>Sinh vi├¬n C├┤ng nghß╗ç th├┤ng tin dß║íy lß║¡p tr├¼nh c╞í bß║ún</li>
                                                    <li>Sinh vi├¬n IELTS 7.5 dß║íy tiß║┐ng Anh</li>
                                                    <li>Sinh vi├¬n n─âm 3, n─âm 4 c├│ th├ánh t├¡ch hß╗ìc tß║¡p tß╗æt</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Tr╞░ß╗¥ng ─æang hß╗ìc, chuy├¬n ng├ánh, n─âm hß╗ìc hiß╗çn tß║íi</li>
                                                    <li>M├┤n c├│ thß╗â dß║íy</li>
                                                    <li>Thß║╗ sinh vi├¬n hoß║╖c minh chß╗⌐ng ─æang hß╗ìc</li>
                                                    <li>Th├ánh t├¡ch hoß║╖c chß╗⌐ng chß╗ë nß║┐u c├│</li>
                                                </ul>
                                            </div>
                                        </label>

                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="certified_pedagogy" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nh├│m 2</span>
                                                <h3 class="teacher-type-title">Giß║úng vi├¬n c├│ chß╗⌐ng chß╗ë s╞░ phß║ím</h3>
                                                <p class="teacher-type-description">Ph├╣ hß╗úp vß╗¢i hß╗ìc vi├¬n cß║ºn ng╞░ß╗¥i dß║íy c├│ nß╗ün tß║úng giß║úng dß║íy, ph╞░╞íng ph├íp truyß╗ün ─æß║ít r├╡ r├áng v├á tß║¡p trung v├áo mß╗Öt sß╗æ m├┤n cß╗Ñ thß╗â.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë nghiß╗çp vß╗Ñ s╞░ phß║ím</li>
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë dß║íy tiß║┐ng Anh</li>
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë ─æ├áo tß║ío kß╗╣ n─âng</li>
                                                    <li>Ng╞░ß╗¥i c├│ chß╗⌐ng chß╗ë dß║íy tin hß╗ìc hoß║╖c lß║¡p tr├¼nh</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Chß╗⌐ng chß╗ë s╞░ phß║ím hoß║╖c chß╗⌐ng chß╗ë giß║úng dß║íy</li>
                                                    <li>M├┤n c├│ thß╗â dß║íy</li>
                                                    <li>Kinh nghiß╗çm dß║íy hß╗ìc nß║┐u c├│</li>
                                                    <li>Hß╗ô s╞í c├í nh├ón v├á minh chß╗⌐ng chuy├¬n m├┤n li├¬n quan</li>
                                                </ul>
                                            </div>
                                        </label>

                                        <label class="teacher-type-card">
                                            <input type="radio" name="teacherType" value="degree_specialist" required>
                                            <div class="teacher-type-card-inner">
                                                <span class="teacher-type-kicker">Nh├│m 3</span>
                                                <h3 class="teacher-type-title">Giß║úng vi├¬n chuy├¬n m├┤n</h3>
                                                <p class="teacher-type-description">D├ánh cho giß║úng vi├¬n, gi├ío vi├¬n ─æ├ú tß╗æt nghiß╗çp, c├│ bß║▒ng cß║Ñp chuy├¬n m├┤n r├╡ r├áng hoß║╖c ─æang/─æ├ú l├ám viß╗çc trong l─⌐nh vß╗▒c giß║úng dß║íy.</p>
                                                <ul class="teacher-type-examples">
                                                    <li>Cß╗¡ nh├ón S╞░ phß║ím To├ín</li>
                                                    <li>Cß╗¡ nh├ón Ng├┤n ngß╗» Anh</li>
                                                    <li>Thß║íc s─⌐ ng├ánh Gi├ío dß╗Ñc</li>
                                                    <li>Gi├ío vi├¬n THCS/THPT, giß║úng vi├¬n ─æß║íi hß╗ìc hoß║╖c chuy├¬n gia ph├╣ hß╗úp</li>
                                                </ul>
                                                <ul class="teacher-type-requirements">
                                                    <li>Bß║▒ng ─æß║íi hß╗ìc, cao hß╗ìc hoß║╖c bß║▒ng chuy├¬n m├┤n</li>
                                                    <li>Chuy├¬n ng├ánh ─æ├áo tß║ío</li>
                                                    <li>Kinh nghiß╗çm giß║úng dß║íy</li>
                                                    <li>M├┤n phß╗Ñ tr├ích, n╞íi tß╗½ng/─æang c├┤ng t├íc nß║┐u c├│</li>
                                                </ul>
                                            </div>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <div class="section-data-card">
                                <div class="card-header-layout">
                                    <div class="card-header-title">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                        <span>Th├┤ng tin x├íc minh</span>
                                    </div>
                                </div>

                                <div style="padding:1.5rem;">
                                    <div class="teacher-registration-form-grid">
                                        <div class="form-group-premium">
                                            <label>Tr╞░ß╗¥ng / ─æ╞ín vß╗ï ─æang hß╗ìc hoß║╖c c├┤ng t├íc</label>
                                            <input type="text" name="institutionName" placeholder="V├¡ dß╗Ñ: ─Éß║íi hß╗ìc S╞░ phß║ím TP.HCM, THPT Chuy├¬n L├¬ Hß╗ông Phong" required>
                                        </div>
                                        <div class="form-group-premium">
                                            <label>Chuy├¬n ng├ánh / l─⌐nh vß╗▒c chuy├¬n m├┤n</label>
                                            <input type="text" name="specialization" placeholder="V├¡ dß╗Ñ: S╞░ phß║ím To├ín, Ng├┤n ngß╗» Anh, C├┤ng nghß╗ç th├┤ng tin" required>
                                        </div>
                                        <div class="form-group-premium">
                                            <label>N─âm hß╗ìc hiß╗çn tß║íi</label>
                                            <select name="currentStudyYear">
                                                <option value="">Kh├┤ng ├íp dß╗Ñng</option>
                                                <option value="year_1">N─âm 1</option>
                                                <option value="year_2">N─âm 2</option>
                                                <option value="year_3">N─âm 3</option>
                                                <option value="year_4">N─âm 4</option>
                                                <option value="year_5_plus">N─âm 5 trß╗ƒ l├¬n</option>
                                                <option value="graduated">─É├ú tß╗æt nghiß╗çp</option>
                                            </select>
                                        </div>
                                        <div class="form-group-premium full-span">
                                            <label>M├┤n c├│ thß╗â dß║íy (C├│ thß╗â chß╗ìn nhiß╗üu m├┤n)</label>
                                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 1rem; margin-top: 0.5rem; background: #f8fafc; padding: 1rem; border-radius: 0.75rem; border: 1px solid var(--border-dark);">
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="To├ín" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> To├ín hß╗ìc
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="V─ân" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Ngß╗» V─ân
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Anh" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Tiß║┐ng Anh
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="L├╜" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Vß║¡t L├╜
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="H├│a" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> H├│a Hß╗ìc
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Sinh Hß╗ìc" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Sinh Hß╗ìc
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="Lß╗ïch Sß╗¡" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Lß╗ïch Sß╗¡
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="─Éß╗ïa L├╜" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> ─Éß╗ïa L├╜
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                    <input type="checkbox" name="teachingSubjects" value="C├┤ng Nghß╗ç" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> C├┤ng Nghß╗ç
                                                </label>
                                                <label style="display:flex; align-items:center; gap:0.5rem; font-weight:500; cursor:pointer; color:var(--text-main); font-size:0.95rem;">
                                                     <input type="checkbox" name="teachingSubjects" value="Tin Hß╗ìc" style="width:1.25rem; height:1.25rem; margin:0; padding:0; flex-shrink:0; border-radius:0.25rem;"> Tin Hß╗ìc
                                                 </label>
                                             </div>
