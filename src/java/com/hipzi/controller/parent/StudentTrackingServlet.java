package com.hipzi.controller.parent;

import com.hipzi.dao.ParentStudentLinkDao;
import com.hipzi.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "StudentTrackingServlet", urlPatterns = {"/parent/tracking"})
public class StudentTrackingServlet extends HttpServlet {

    private final ParentStudentLinkDao linkDao = new ParentStudentLinkDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        try {
            HttpSession session = request.getSession(false);
            User parent = (session != null) ? (User) session.getAttribute("loggedUser") : null;

            if (parent == null || parent.getId() == null) {
                writePlain(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
                return;
            }

            String action = request.getParameter("action");
            if ("link".equals(action)) {
                linkStudent(request, response, parent);
            } else if ("unlink".equals(action)) {
                unlinkStudent(request, response, parent);
            } else {
                writePlain(response, HttpServletResponse.SC_BAD_REQUEST, "Yêu cầu không hợp lệ.");
            }
        } catch (Exception e) {
            System.err.println("Error in StudentTrackingServlet.doPost: " + e.getMessage());
            e.printStackTrace();
            writePlain(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Có lỗi hệ thống khi kết nối học viên. Vui lòng thử lại.");
        }
    }

    private void linkStudent(HttpServletRequest request, HttpServletResponse response, User parent)
            throws IOException {
        String studentCode = normalizeCode(request.getParameter("studentCode"));

        if (studentCode.isEmpty()) {
            writePlain(response, HttpServletResponse.SC_BAD_REQUEST, "Mã học viên không được để trống.");
            return;
        }

        String studentId = linkDao.findStudentIdByCode(studentCode);
        if (studentId == null) {
            writePlain(response, HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy học viên với mã này. Vui lòng kiểm tra lại mã trên trang học viên.");
            return;
        }

        if (studentId.equalsIgnoreCase(parent.getId())) {
            writePlain(response, HttpServletResponse.SC_CONFLICT,
                    "Bạn không thể tự theo dõi chính mình.");
            return;
        }

        boolean success = linkDao.createLink(parent.getId(), studentId);
        if (success) {
            writePlain(response, HttpServletResponse.SC_OK, "Kết nối thành công!");
        } else {
            writePlain(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể tạo liên kết. Vui lòng kiểm tra bảng parent_student_links trong Supabase.");
        }
    }

    private void unlinkStudent(HttpServletRequest request, HttpServletResponse response, User parent)
            throws IOException {
        String studentId = request.getParameter("studentId");
        if (studentId == null || studentId.trim().isEmpty()) {
            writePlain(response, HttpServletResponse.SC_BAD_REQUEST, "Thiếu ID học viên.");
            return;
        }

        boolean success = linkDao.deleteLink(parent.getId(), studentId.trim());
        if (success) {
            writePlain(response, HttpServletResponse.SC_OK, "Đã hủy liên kết thành công.");
        } else {
            writePlain(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể hủy liên kết. Vui lòng thử lại.");
        }
    }

    private String normalizeCode(String code) {
        if (code == null) return "";
        return code.trim().replaceAll("\\s+", "").toUpperCase();
    }

    private void writePlain(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.getWriter().write(message);
        response.getWriter().flush();
        response.flushBuffer();
    }
}
