let deferredPrompt;
let bannerReady = false;

// Listen for the beforeinstallprompt event at the top level so we don't miss it
window.addEventListener('beforeinstallprompt', (e) => {
    // Prevent Chrome 67 and earlier from automatically showing the prompt
    e.preventDefault();
    // Stash the event so it can be triggered later.
    deferredPrompt = e;
    
    // Check if the user already dismissed the prompt recently (e.g. keep hidden for 1 hour)
    const dismissedTime = localStorage.getItem('pwa-dismissed-time');
    const now = new Date().getTime();
    const hideDuration = 1 * 60 * 60 * 1000; // 1 hour in milliseconds
    
    if (!dismissedTime || (now - parseInt(dismissedTime, 10)) > hideDuration) {
        bannerReady = true;
        
        // If DOM is already loaded, show it immediately
        const pwaBanner = document.getElementById('pwa-install-banner');
        if (pwaBanner) {
            pwaBanner.style.display = 'flex';
            checkScrollGlobal();
        }
    }
});

// For testing/design purposes, forcefully show it on localhost
if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    setTimeout(() => {
        bannerReady = true;
        const pwaBanner = document.getElementById('pwa-install-banner');
        if (pwaBanner) {
            pwaBanner.style.display = 'flex';
            checkScrollGlobal();
        }
    }, 1500);
}

function checkScrollGlobal() {
    if (!bannerReady) return;
    const pwaBanner = document.getElementById('pwa-install-banner');
    if (!pwaBanner) return;
    
    if (window.scrollY > 50) {
        pwaBanner.classList.add('is-visible');
    } else {
        pwaBanner.classList.remove('is-visible');
    }
}

window.addEventListener('scroll', checkScrollGlobal, { passive: true });

document.addEventListener('DOMContentLoaded', () => {
    // Register Service Worker for PWA
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/HipZi/sw.js')
            .then(registration => {
                console.log('SW registered:', registration);
            })
            .catch(error => {
                console.log('SW registration failed:', error);
            });
    }

    const pwaBanner = document.getElementById('pwa-install-banner');
    const installBtn = document.getElementById('pwa-install-btn');
    const dismissBtn = document.getElementById('pwa-dismiss-btn');

    if (!pwaBanner) return;
    
    // If beforeinstallprompt already fired before DOMContentLoaded
    if (bannerReady) {
        pwaBanner.style.display = 'flex';
        checkScrollGlobal();
    }

    // Handle install button click
    if (installBtn) {
        installBtn.addEventListener('click', async () => {
            if (deferredPrompt) {
                // Hide our user interface that shows our A2HS button
                bannerReady = false;
                pwaBanner.classList.remove('is-visible');
                setTimeout(() => pwaBanner.style.display = 'none', 400);
                
                // Show the prompt
                deferredPrompt.prompt();
                
                // Wait for the user to respond to the prompt
                const { outcome } = await deferredPrompt.userChoice;
                console.log(`User response to the install prompt: ${outcome}`);
                
                // We've used the prompt, and can't use it again, throw it away
                deferredPrompt = null;
            } else {
                // Trình duyệt không hỗ trợ hoặc đang chặn prompt (do vừa gỡ cài đặt)
                // Thay đổi nội dung banner để hướng dẫn người dùng tự cài
                const textDiv = pwaBanner.querySelector('.pwa-text');
                if (textDiv) {
                    textDiv.innerHTML = `
                        <strong>Hướng dẫn cài đặt thủ công</strong>
                        <p>Nhấp vào biểu tượng 📱 (hoặc ⬇️) trên thanh địa chỉ URL, hoặc vào Menu (⋮) > Cài đặt ứng dụng.</p>
                    `;
                }
                installBtn.style.display = 'none'; // Ẩn nút cài đặt đi vì không dùng được
            }
        });
    }

    // Handle dismiss button click
    if (dismissBtn) {
        dismissBtn.addEventListener('click', () => {
            bannerReady = false;
            pwaBanner.classList.remove('is-visible');
            setTimeout(() => pwaBanner.style.display = 'none', 400);
            
            // Save dismiss time to local storage
            localStorage.setItem('pwa-dismissed-time', new Date().getTime().toString());
        });
    }

    // Handle successful installation
    window.addEventListener('appinstalled', (evt) => {
        // Log install to analytics
        console.log('HIPZI App was installed successfully');
        
        // Hide the banner if it is visible
        bannerReady = false;
        if(pwaBanner) {
            pwaBanner.classList.remove('is-visible');
            setTimeout(() => pwaBanner.style.display = 'none', 400);
        }
        
        // Clear deferredPrompt
        deferredPrompt = null;
    });
});
