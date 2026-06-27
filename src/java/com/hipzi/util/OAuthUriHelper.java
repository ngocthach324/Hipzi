package com.hipzi.util;

import jakarta.servlet.http.HttpServletRequest;
import java.net.URI;

public class OAuthUriHelper {

    public static String callbackUri(HttpServletRequest request, String configuredUri, String defaultCallbackPath) {
        if (shouldUseConfiguredCallback(request, configuredUri)) {
            return configuredUri;
        }
        return externalBaseUrl(request) + request.getContextPath() + defaultCallbackPath;
    }

    private static String externalBaseUrl(HttpServletRequest request) {
        String scheme = request.getHeader("X-Forwarded-Proto");
        if (isBlank(scheme)) {
            scheme = request.getScheme();
        }

        String forwardedHost = request.getHeader("X-Forwarded-Host");
        if (!isBlank(forwardedHost)) {
            return scheme + "://" + forwardedHost;
        }

        String hostHeader = request.getHeader("Host");
        if (!isBlank(hostHeader)) {
            return scheme + "://" + hostHeader;
        }

        String host = request.getServerName();
        if (host.contains(":")) {
            return scheme + "://" + host;
        }

        int port = request.getServerPort();
        boolean defaultPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443)
                // If it's https but the proxy forwarded to 8080 (like in Docker Tomcat), don't append 8080
                || ("https".equalsIgnoreCase(scheme) && port == 8080);

        String portPart = defaultPort ? "" : ":" + port;
        return scheme + "://" + host + portPart;
    }

    private static boolean shouldUseConfiguredCallback(HttpServletRequest request, String configured) {
        if (isBlank(configured)) {
            return false;
        }
        try {
            URI configuredUri = URI.create(configured);
            String configuredHost = configuredUri.getHost();
            String requestHost = request.getHeader("X-Forwarded-Host");
            if (isBlank(requestHost)) {
                requestHost = request.getServerName();
            }
            if (requestHost != null && requestHost.contains(":")) {
                requestHost = requestHost.substring(0, requestHost.indexOf(':'));
            }
            if (isLocalHost(configuredHost) && !isLocalHost(requestHost)) {
                return false;
            }
        } catch (Exception ignored) {
            return false;
        }
        return true;
    }

    private static boolean isLocalHost(String host) {
        return "localhost".equalsIgnoreCase(host)
                || "127.0.0.1".equals(host)
                || "::1".equals(host);
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
