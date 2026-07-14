(function () {
    const root = document.querySelector('[data-hipzi-chat]');
    if (!root) return;

    const launcher = root.querySelector('[data-chat-launcher]');
    const panel = root.querySelector('.hipzi-chat__panel');
    const closeButton = root.querySelector('[data-chat-close]');
    const form = root.querySelector('[data-chat-form]');
    const input = root.querySelector('[data-chat-input]');
    const messages = root.querySelector('[data-chat-messages]');
    const body = root.querySelector('[data-chat-body]');
    const sendButton = root.querySelector('[data-chat-send]');
    const chips = root.querySelectorAll('[data-chat-chip]');
    const endpoint = root.dataset.chatEndpoint || '/ai-chat';
    let touchStartY = 0;

    function setOpen(open) {
        root.classList.toggle('is-open', open);
        launcher.setAttribute('aria-expanded', open ? 'true' : 'false');
        if (open && input) {
            setTimeout(() => input.focus(), 160);
            scrollBottom();
        }
    }

    function scrollBottom() {
        if (body) body.scrollTop = body.scrollHeight;
    }

    function currentTime() {
        return new Date().toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    }

    function appendMessage(text, owner, isHtml = false) {
        if (!messages || !text.trim()) return;
        const item = document.createElement('div');
        item.className = 'hipzi-chat__message hipzi-chat__message--' + owner;
        item.innerHTML = '<div class="hipzi-chat__bubble"></div><span class="hipzi-chat__time"></span>';
        if (isHtml) {
            item.querySelector('.hipzi-chat__bubble').innerHTML = text.replace(/\n/g, '<br>');
        } else {
            item.querySelector('.hipzi-chat__bubble').textContent = text;
        }
        item.querySelector('.hipzi-chat__time').textContent = currentTime();
        messages.appendChild(item);
        scrollBottom();
    }

    function canScrollBody() {
        return body && body.scrollHeight > body.clientHeight;
    }

    function scrollChatBody(deltaY, event) {
        if (!root.classList.contains('is-open') || !body) return false;
        event.preventDefault();
        event.stopPropagation();
        if (!canScrollBody()) return true;
        const atTop = body.scrollTop <= 0;
        const atBottom = body.scrollTop + body.clientHeight >= body.scrollHeight - 1;
        if (!((deltaY < 0 && atTop) || (deltaY > 0 && atBottom))) {
            body.scrollTop += deltaY;
        }
        return true;
    }

    function containPanelScroll(event, deltaY) {
        if (!root.classList.contains('is-open')) return;
        if (panel && panel.contains(event.target)) {
            scrollChatBody(deltaY, event);
        }
    }

    async function requestReply(text) {
        root.classList.add('is-typing');
        scrollBottom();
        try {
            const response = await fetch(endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ message: text })
            });
            const data = await response.json();
            root.classList.remove('is-typing');
            appendMessage(data.reply || 'Hipzi AI ch\\u01b0a c\\u00f3 ph\\u1ea3n h\\u1ed3i ph\\u00f9 h\\u1ee3p.', 'bot', data.isHtml === true);
        } catch (error) {
            root.classList.remove('is-typing');
            appendMessage('Hipzi AI \\u0111ang b\\u1eadn m\\u1ed9t ch\\u00fat. B\\u1ea1n th\\u1eed l\\u1ea1i sau nh\\u00e9.', 'bot');
        }
    }

    launcher?.addEventListener('click', () => setOpen(!root.classList.contains('is-open')));
    closeButton?.addEventListener('click', () => setOpen(false));

    body?.addEventListener('wheel', event => {
        scrollChatBody(event.deltaY, event);
    }, { passive: false });

    body?.addEventListener('touchstart', event => {
        touchStartY = event.touches[0]?.clientY || 0;
    }, { passive: true });

    body?.addEventListener('touchmove', event => {
        const currentY = event.touches[0]?.clientY || touchStartY;
        scrollChatBody(touchStartY - currentY, event);
        touchStartY = currentY;
    }, { passive: false });

    document.addEventListener('wheel', event => {
        containPanelScroll(event, event.deltaY);
    }, { passive: false, capture: true });

    document.addEventListener('touchmove', event => {
        const currentY = event.touches[0]?.clientY || touchStartY;
        containPanelScroll(event, touchStartY - currentY);
        touchStartY = currentY;
    }, { passive: false, capture: true });

    chips.forEach(chip => {
        chip.addEventListener('click', () => {
            setOpen(true);
            if (input) input.value = chip.dataset.chatChip || chip.textContent.trim();
            input?.focus();
        });
    });

    input?.addEventListener('input', () => {
        if (sendButton) sendButton.disabled = input.value.trim().length === 0;
        input.style.height = 'auto';
        input.style.height = Math.min(input.scrollHeight, 112) + 'px';
    });

    input?.addEventListener('keydown', event => {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            form?.requestSubmit();
        }
    });

    form?.addEventListener('submit', event => {
        event.preventDefault();
        const text = input ? input.value.trim() : '';
        if (!text) return;
        appendMessage(text, 'user');
        input.value = '';
        input.style.height = 'auto';
        if (sendButton) sendButton.disabled = true;
        requestReply(text);
    });
})();
