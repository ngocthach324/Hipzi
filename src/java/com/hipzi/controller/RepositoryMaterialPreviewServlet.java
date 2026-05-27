package com.hipzi.controller;

import com.hipzi.dao.RepositoryMaterialDao;
import com.hipzi.model.Material;
import com.hipzi.service.SupabaseStorageService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RepositoryMaterialPreviewServlet", urlPatterns = {"/repository-material-preview"})
public class RepositoryMaterialPreviewServlet extends HttpServlet {
    private final RepositoryMaterialDao repositoryMaterialDao = new RepositoryMaterialDao();
    private final SupabaseStorageService storageService = new SupabaseStorageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String materialId = cleanParam(request.getParameter("id"));
        Material material = !materialId.isEmpty() ? repositoryMaterialDao.findById(materialId) : null;
        if (material == null || material.getFilePath() == null || material.getFilePath().isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay tai lieu.");
            return;
        }

        try {
            repositoryMaterialDao.incrementViewCount(material.getId());
            request.setAttribute("material", material);
            request.setAttribute("signedUrl", storageService.createSignedUrl(material.getFilePath(), 900));
            request.getRequestDispatcher("/repository-material-preview.jsp").forward(request, response);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Khong tao duoc link xem truoc tu Supabase Storage.");
        }
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}
