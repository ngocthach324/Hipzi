package com.hipzi.controller;

import com.hipzi.service.B2StorageService;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CourseThumbnailServlet", urlPatterns = {"/course-thumbnail"})
public class CourseThumbnailServlet extends HttpServlet {

    private final B2StorageService b2StorageService = new B2StorageService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String objectPath = request.getParameter("p");

        if (objectPath == null || objectPath.isBlank()
                || objectPath.contains("..")
                || !objectPath.startsWith("course-thumbnails/")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            // Generate a signed URL valid for 7 days (604800 seconds)
            String signedUrl = b2StorageService.createSignedUrl(objectPath, 604800);
            response.sendRedirect(signedUrl);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
