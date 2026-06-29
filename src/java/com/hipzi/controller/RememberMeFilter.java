package com.hipzi.controller;

import com.hipzi.model.User;
import com.hipzi.service.RememberMeService;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "RememberMeFilter", urlPatterns = {"/*"})
public class RememberMeFilter implements Filter {

    private final RememberMeService rememberMeService = new RememberMeService();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if (!isStaticAsset(httpRequest)) {
            HttpSession session = httpRequest.getSession(false);
            boolean loggedIn = session != null && session.getAttribute("loggedUser") != null;
            if (!loggedIn) {
                User rememberedUser = rememberMeService.consumeRememberCookie(httpRequest, httpResponse);
                if (rememberedUser != null) {
                    session = httpRequest.getSession(true);
                    session.setAttribute("loggedUser", rememberedUser);
                    loggedIn = true;
                }
            }

            if (!loggedIn && !isPublicPage(httpRequest)) {
                String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
                if (path.startsWith("/api/")) {
                    // API request: trả về JSON 401 thay vì redirect HTML
                    httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    httpResponse.setContentType("application/json");
                    httpResponse.setCharacterEncoding("UTF-8");
                    httpResponse.getWriter().print("{\"success\":false,\"message\":\"Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.\"}");
                    return;
                }
                
                if (session == null) {
                    session = httpRequest.getSession(true);
                }
                String fullPath = httpRequest.getRequestURI();
                String queryString = httpRequest.getQueryString();
                if (queryString != null) {
                    fullPath += "?" + queryString;
                }
                session.setAttribute("redirectUrl", fullPath);
                
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isPublicPage(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        if (path == null || path.isEmpty() || "/".equals(path)) {
            return true;
        }

        return path.equals("/index")
                || path.equals("/index.html")
                || path.equals("/courses")
                || path.equals("/login")
                || path.equals("/login")
                || path.equals("/register")
                || path.equals("/register")
                || path.equals("/forgot-password")
                || path.equals("/forgot-password")
                || path.equals("/verify-otp")
                || path.equals("/verify-otp")
                || path.equals("/send-register-otp")
                || path.equals("/ai-chat")
                || path.equals("/auth/google")
                || path.equals("/auth/google/callback")
                || path.equals("/payment/sepay/webhook");
    }

    private boolean isStaticAsset(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        return path.equals("/manifest.json")
                || path.startsWith("/assets/")
                || path.startsWith("/favicon")
                || path.endsWith(".png")
                || path.endsWith(".jpg")
                || path.endsWith(".jpeg")
                || path.endsWith(".webp")
                || path.endsWith(".css")
                || path.endsWith(".js");
    }
}
