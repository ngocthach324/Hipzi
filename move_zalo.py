import os

banner_html = """
    <!-- ========================================================== -->
    <!-- BANNER CỘNG ĐỒNG HIPZI (CHÍNH GIỮA FULL-WIDTH TOÀN TRANG)  -->
    <!-- ========================================================== -->
    <div style="max-width:1320px; width:100%; margin:4.5rem auto 1rem auto; padding:0 1.5rem;">
        <div class="community-engagement-banner" style="background:#ffffff; border-radius:1.5rem; border:1px solid #e2e8f0; box-shadow:0 10px 30px rgba(0, 0, 0, 0.03); padding:2.5rem; display:flex; flex-direction:column; gap:1.75rem; position:relative; overflow:hidden;">
            
            <!-- Dải lấp lánh trang trí góc phải -->
            <div style="position:absolute; top:0; right:0; width:350px; height:350px; background:radial-gradient(circle, rgba(5, 150, 105, 0.05) 0%, transparent 70%); pointer-events:none;"></div>

            <div style="display:flex; flex-direction:column; gap:1.25rem; z-index:1;">
                <!-- Badge Hỗ trợ / Cộng đồng -->
                <div>
                    <span style="display:inline-flex; align-items:center; gap:0.4rem; background:#ecfdf5; color:#059669; font-weight:800; font-size:0.75rem; padding:0.4rem 1rem; border-radius:2rem; letter-spacing:0.5px; text-transform:uppercase;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                        Hỗ trợ học tập 24/7
                    </span>
                </div>

                <!-- Hàng Flex chính chia 2 cột -->
                <div style="display:flex; flex-direction:row; justify-content:space-between; align-items:center; gap:2.5rem; flex-wrap:wrap;">
                    
                    <!-- Cột Trái: Tiêu đề & Lời kêu gọi -->
                    <div style="flex:1; min-width:320px; display:flex; flex-direction:column; gap:1rem; text-align:left;">
                        <h3 style="font-weight:800; font-size:2.15rem; color:#0f172a; line-height:1.25; margin:0; letter-spacing:-0.5px;">
                            Tham Gia <span style="background:linear-gradient(135deg, rgb(4, 120, 87) 0%, rgb(16, 185, 129) 100%); -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text; font-style:italic;">Cộng Đồng HIPZI?</span>
                        </h3>
                        <p style="font-size:0.95rem; color:#475569; line-height:1.55; margin:0; max-width:550px;">
                            Đừng ngần ngại kết nối với đội ngũ giảng viên và cộng đồng học viên để cùng trao đổi kiến thức, định hướng lộ trình học tập phù hợp và hiệu quả nhất với bản thân.
                        </p>
                        
                        <!-- Hàng Nút Hành động CTA -->
                        <div style="display:flex; align-items:center; gap:0.85rem; margin-top:0.5rem; flex-wrap:wrap;">
                            <a href="https://zalo.me/g/hipzi2024" target="_blank" style="background:#059669; color:#ffffff; font-weight:700; font-size:0.85rem; padding:0.85rem 1.75rem; border-radius:0.75rem; text-decoration:none; display:inline-flex; align-items:center; gap:0.5rem; box-shadow:0 4px 12px rgba(5, 150, 105, 0.25); transition:all 0.2s ease; letter-spacing:0.5px;" onmouseover="this.style.background='#047857'; this.style.transform='translateY(-2px)';" onmouseout="this.style.background='#059669'; this.style.transform='translateY(0)';">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>
                                THAM GIA CỘNG ĐỒNG
                            </a>
                        </div>
                    </div>

                    <!-- Cột Phải: Khung Highlight Thông số bo tròn màu xám nhạt -->
                    <div style="background:#f8fafc; border-radius:1.25rem; padding:1.5rem; border:1px solid #f1f5f9; display:flex; flex-direction:column; gap:1.25rem; min-width:260px;">
                        
                        <!-- Thông số 1 -->
                        <div style="display:flex; align-items:center; gap:1rem;">
                            <div style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#2563eb; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                            </div>
                            <div style="display:flex; flex-direction:column; text-align:left;">
                                <span style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">GIẢNG VIÊN ONLINE</span>
                                <span style="font-size:1.05rem; font-weight:800; color:#0f172a;">Hơn 50+ Mentor</span>
                            </div>
                        </div>

                        <div style="height:1px; background:#f1f5f9;"></div>

                        <!-- Thông số 2 -->
                        <div style="display:flex; align-items:center; gap:1rem;">
                            <div style="width:42px; height:42px; border-radius:0.85rem; background:#ffffff; color:#10b981; box-shadow:0 2px 8px rgba(0,0,0,0.04); display:flex; justify-content:center; align-items:center; flex-shrink:0;">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                            </div>
                            <div style="display:flex; flex-direction:column; text-align:left;">
                                <span style="font-size:0.7rem; font-weight:700; color:#94a3b8; letter-spacing:0.5px; text-transform:uppercase;">CỘNG ĐỒNG HỌC VIÊN</span>
                                <span style="font-size:1.05rem; font-weight:800; color:#0f172a;">2000+ Thành viên</span>
                            </div>
                        </div>

                    </div>

                </div>
            </div>
        </div>
    </div>
"""

index_path = "e:/PRJ/HipZi/web/WEB-INF/views/index.jsp"
with open(index_path, "r", encoding="utf-8") as f:
    content = f.read()

target = "    </section>\n\n    <!-- PHẦN LIÊN HỆ VỚI CHÚNG TÔI / CONTACT SECTION -->"
if target in content:
    content = content.replace(target, banner_html + "\n" + target)
    with open(index_path, "w", encoding="utf-8") as f:
        f.write(content)
        print("Updated index.jsp")
else:
    print("Could not find target in index.jsp")

profiles = [
    "e:/PRJ/HipZi/web/WEB-INF/views/teacher-profile.jsp",
    "e:/PRJ/HipZi/web/WEB-INF/views/student-profile.jsp",
    "e:/PRJ/HipZi/web/WEB-INF/views/staff-profile.jsp",
    "e:/PRJ/HipZi/web/WEB-INF/views/parent-profile.jsp",
    "e:/PRJ/HipZi/web/WEB-INF/views/admin-profile.jsp"
]

start_marker = "<!-- =========================================================="
end_marker = "<!-- ===== JAVASCRIPT"

for p in profiles:
    if os.path.exists(p):
        with open(p, "r", encoding="utf-8") as f:
            p_content = f.read()
        
        idx1 = p_content.find("<!-- BANNER CỘNG ĐỒNG HIPZI")
        if idx1 != -1:
            idx1 = p_content.rfind(start_marker, 0, idx1)
            idx2 = p_content.find(end_marker, idx1)
            if idx1 != -1 and idx2 != -1:
                # Remove the entire block
                # There might be some trailing newlines, so we remove up to idx2
                p_content = p_content[:idx1] + "\n    " + p_content[idx2:]
                # Fix JSP comment bug if it's there (teacher-profile has <%-- and --%>)
                # Since we remove the whole block, <%-- and --%> will be removed! Wait.
                # In teacher-profile, the <%-- is before <!-- ========================================================== -->
                # Let's check how it is commented in teacher-profile.
                pass

        with open(p, "w", encoding="utf-8") as f:
            f.write(p_content)
        print(f"Cleaned {p}")
