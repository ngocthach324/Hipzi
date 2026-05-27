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

@WebServlet(name = "RepositoryMaterialFileServlet", urlPatterns = {"/repository-material-file"})
public class RepositoryMaterialFileServlet extends HttpServlet {
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
            String signedUrl = storageService.createSignedUrl(material.getFilePath(), 600);
            String mode = cleanParam(request.getParameter("mode"));
            if ("download".equalsIgnoreCase(mode)) {
                signedUrl += signedUrl.contains("?") ? "&download" : "?download";
            }
            response.sendRedirect(signedUrl);
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Khong tao duoc link tai lieu tu Supabase Storage.");
        }
    }

    private String cleanParam(String value) {
        return value == null ? "" : value.trim();
    }
}
