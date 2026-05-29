/**
 * HIPZI Page Transition System — v4
 *
 * Kỹ thuật tối ưu:
 *  1. Hover-based prefetch  — tải trước HTML khi chuột hover vào link
 *  2. Speculation Rules API — prefetch toàn trang trong nền
 *  3. Chống double click    — ngăn click nhiều lần trong lúc chờ load
 *  4. Bảo vệ form chưa lưu  — cảnh báo trước khi rời trang
 */
(function () {
    'use strict';

    // Temporarily disabled while we profile real navigation latency.
    // Flip this back to true if we want to test prefetch/navigation handling again.
    var PAGE_TRANSITIONS_ENABLED = false;
    if (!PAGE_TRANSITIONS_ENABLED) return;

    var isNavigating = false;

    // ── Helpers ──────────────────────────────────────────────────────────────
    function isSameOriginPageLink(anchor) {
        if (!anchor || anchor.tagName !== 'A') return false;

        var hrefAttr = anchor.getAttribute('href');
        if (!hrefAttr || hrefAttr === '#' || hrefAttr.startsWith('javascript:')) return false;
        if (/^(mailto:|tel:|sms:)/i.test(hrefAttr)) return false;
        if (anchor.hasAttribute('download')) return false;

        var target = anchor.getAttribute('target');
        if (target && target !== '_self') return false;

        try {
            var url = new URL(anchor.href, window.location.origin);
            if (url.origin !== window.location.origin) return false;
            // Bỏ qua: chỉ là fragment trên cùng trang
            if (url.pathname === window.location.pathname && url.hash) return false;
            // Bỏ qua: đúng trang hiện tại
            if (url.href === window.location.href) return false;
        } catch (e) {
            return false;
        }
        return true;
    }

    function isNavLink(anchor) {
        // Bỏ qua link trong sidebar AJAX (có handler riêng)
        return !anchor.closest('.subject-list, .classes-sidebar, form');
    }

    function shouldBlockNavigation() {
        return document.body.classList.contains('has-unsaved-changes');
    }

    // ── 1. Hover Prefetch ─────────────────────────────────────────────────────
    var HOVER_DELAY = 120; // ms
    var PREFETCH_LIMIT = 20;
    var prefetchCache = {};
    var prefetchList = [];
    var hoverTimer = null;
    var lastHref = null;

    function canPrefetch() {
        var conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
        if (!conn) return true;
        if (conn.saveData) return false;
        if (/(slow-2g|2g)/.test(conn.effectiveType)) return false;
        return true;
    }

    function prefetch(href) {
        if (!canPrefetch()) return;
        if (prefetchCache[href]) return;

        if (prefetchList.length >= PREFETCH_LIMIT) {
            var oldHref = prefetchList.shift();
            delete prefetchCache[oldHref];
        }

        prefetchCache[href] = true;
        prefetchList.push(href);

        var link = document.createElement('link');
        link.rel = 'prefetch';
        link.href = href;
        link.as = 'document';
        document.head.appendChild(link);
    }

    document.addEventListener('mouseover', function (e) {
        var anchor = e.target.closest('a');
        if (!anchor) return;
        if (!isSameOriginPageLink(anchor) || !isNavLink(anchor)) return;

        var href = anchor.href;
        if (prefetchCache[href]) return; 

        if (hoverTimer) { clearTimeout(hoverTimer); hoverTimer = null; }
        lastHref = href;
        hoverTimer = setTimeout(function () {
            if (lastHref === href) prefetch(href);
        }, HOVER_DELAY);
    }, { passive: true });

    document.addEventListener('mouseout', function (e) {
        if (hoverTimer) { clearTimeout(hoverTimer); hoverTimer = null; }
    }, { passive: true });

    document.addEventListener('touchstart', function (e) {
        var anchor = e.target.closest('a');
        if (!anchor) return;
        if (!isSameOriginPageLink(anchor) || !isNavLink(anchor)) return;
        prefetch(anchor.href);
    }, { passive: true });

    // ── 2. Speculation Rules API (Chrome 108+) ────────────────────────────────
    function injectSpeculationRules() {
        if (!HTMLScriptElement.supports || !HTMLScriptElement.supports('speculationrules')) return;

        var navUrls = [];
        var seen = {};
        var navLinks = document.querySelectorAll('.nav-links a, .footer a');
        
        navLinks.forEach(function (a) {
            if (!isSameOriginPageLink(a)) return;
            var url = new URL(a.href, window.location.origin);
            if (/\/(index\.jsp|material-repository|classes|practice|exam-room)/.test(url.pathname)) {
                if (!seen[url.href]) {
                    seen[url.href] = true;
                    navUrls.push(url.href);
                }
            }
        });

        if (navUrls.length === 0) return;

        var rules = {
            prefetch: [{
                urls: navUrls,
                eagerness: 'moderate'
            }]
        };

        var script = document.createElement('script');
        script.type = 'speculationrules';
        script.textContent = JSON.stringify(rules);
        document.head.appendChild(script);
    }

    // ── 3. Navigation ─────────────────────────────────────────────────────────

    function navigateTo(href) {
        if (isNavigating) return;
        isNavigating = true;
        window.location.href = href;
    }

    // Điều hướng thật sự ở sự kiện click
    document.addEventListener('click', function (e) {
        if (e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;

        var anchor = e.target.closest('a');
        if (!anchor) return;
        if (!isSameOriginPageLink(anchor) || !isNavLink(anchor)) return;

        e.preventDefault();

        // Kiểm tra unsaved changes
        if (shouldBlockNavigation()) {
            var ok = window.confirm('Bạn có thay đổi chưa lưu. Bạn vẫn muốn rời trang?');
            if (!ok) {
                return;
            }
        }

        navigateTo(anchor.href);
    }, true);

    // ── 4. Khởi động khi trang load xong ─────────────────────────────────────
    document.addEventListener('DOMContentLoaded', function () {
        injectSpeculationRules();
    });

    // Reset nếu quay lại bằng nút Back/Forward (bfcache)
    window.addEventListener('pageshow', function (e) {
        isNavigating = false;
    });

})();
