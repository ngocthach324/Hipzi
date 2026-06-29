let deferredPrompt = null;
let bannerReady = false;

const pwaScript = document.currentScript;
const appContextPath = (pwaScript && pwaScript.dataset.contextPath) || '';
const DISMISS_KEY = 'pwa-dismissed-time';
const DISMISS_DURATION = 60 * 60 * 1000;

function isStandalone() {
    return window.matchMedia('(display-mode: standalone)').matches
        || window.navigator.standalone === true;
}

function wasDismissedRecently() {
    const dismissedTime = Number(localStorage.getItem(DISMISS_KEY));
    return Number.isFinite(dismissedTime)
        && Date.now() - dismissedTime < DISMISS_DURATION;
}

function showInstallBanner() {
    if (isStandalone() || wasDismissedRecently()) return;

    bannerReady = true;
    const banner = document.getElementById('pwa-install-banner');
    if (!banner) return;

    banner.style.display = 'flex';
    checkScrollGlobal();
}

function hideInstallBanner() {
    bannerReady = false;
    const banner = document.getElementById('pwa-install-banner');
    if (!banner) return;

    banner.classList.remove('is-visible');
    window.setTimeout(() => {
        banner.style.display = 'none';
    }, 400);
}

// Capture the native install event as early as possible.
window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredPrompt = event;
    showInstallBanner();
});

function checkScrollGlobal() {
    if (!bannerReady) return;
    const banner = document.getElementById('pwa-install-banner');
    if (!banner) return;

    banner.classList.toggle('is-visible', window.scrollY > 50);
}

window.addEventListener('scroll', checkScrollGlobal, { passive: true });

document.addEventListener('DOMContentLoaded', () => {
    if ('serviceWorker' in navigator) {
        const serviceWorkerUrl = `${appContextPath}/sw.js`;
        const serviceWorkerScope = `${appContextPath}/` || '/';

        navigator.serviceWorker.register(serviceWorkerUrl, { scope: serviceWorkerScope })
            .then(registration => console.log('SW registered:', registration))
            .catch(error => console.warn('SW registration failed:', error));
    }

    const banner = document.getElementById('pwa-install-banner');
    const installBtn = document.getElementById('pwa-install-btn');
    const dismissBtn = document.getElementById('pwa-dismiss-btn');

    if (!banner || isStandalone()) return;

    if (bannerReady) showInstallBanner();

    // Keep the download entry visible on production even when a browser does
    // not expose beforeinstallprompt. The button then provides instructions.
    window.setTimeout(showInstallBanner, 1500);

    if (installBtn) {
        installBtn.addEventListener('click', async () => {
            if (deferredPrompt) {
                hideInstallBanner();
                deferredPrompt.prompt();
                await deferredPrompt.userChoice;
                deferredPrompt = null;
                return;
            }

            const text = banner.querySelector('.pwa-text');
            if (text) {
                text.innerHTML = `
                    <strong>Hướng dẫn cài đặt</strong>
                    <p>Mở menu trình duyệt rồi chọn “Cài đặt ứng dụng” hoặc “Thêm vào màn hình chính”.</p>
                `;
            }
            installBtn.style.display = 'none';
        });
    }

    if (dismissBtn) {
        dismissBtn.addEventListener('click', () => {
            localStorage.setItem(DISMISS_KEY, String(Date.now()));
            hideInstallBanner();
        });
    }

    window.addEventListener('appinstalled', () => {
        console.log('HIPZI App was installed successfully');
        deferredPrompt = null;
        localStorage.removeItem(DISMISS_KEY);
        hideInstallBanner();
    });
});
