(function () {
    'use strict';

    function initMobileNavigation() {
        const toggle = document.querySelector('.mobile-nav-toggle');
        const menu = document.getElementById('mobile-home-nav');
        if (!toggle || !menu) return;

        const closeMenu = (restoreFocus) => {
            toggle.setAttribute('aria-expanded', 'false');
            toggle.setAttribute('aria-label', 'Mở menu điều hướng');
            toggle.classList.remove('is-open');
            menu.hidden = true;
            document.body.classList.remove('mobile-nav-open');
            if (restoreFocus) toggle.focus();
        };

        const openMenu = () => {
            toggle.setAttribute('aria-expanded', 'true');
            toggle.setAttribute('aria-label', 'Đóng menu điều hướng');
            toggle.classList.add('is-open');
            menu.hidden = false;
            document.body.classList.add('mobile-nav-open');
        };

        toggle.addEventListener('click', () => {
            if (toggle.getAttribute('aria-expanded') === 'true') {
                closeMenu(false);
            } else {
                openMenu();
            }
        });

        menu.addEventListener('click', event => {
            if (event.target.closest('a')) closeMenu(false);
        });

        document.addEventListener('click', event => {
            if (!menu.hidden && !event.target.closest('.navbar')) closeMenu(false);
        });

        document.addEventListener('keydown', event => {
            if (event.key === 'Escape' && !menu.hidden) closeMenu(true);
        });

        window.addEventListener('resize', () => {
            if (window.innerWidth > 768 && !menu.hidden) closeMenu(false);
        }, { passive: true });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initMobileNavigation);
    } else {
        initMobileNavigation();
    }
})();
