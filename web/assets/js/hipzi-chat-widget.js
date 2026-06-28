(function () {
    const root = document.querySelector('[data-hipzi-chat]');
    if (!root) return;

    const launcher = root.querySelector('[data-chat-launcher]');
    const closeButton = root.querySelector('[data-chat-close]');
    const form = root.querySelector('[data-chat-form]');
    const input = root.querySelector('[data-chat-input]');
    const messages = root.querySelector('[data-chat-messages]');
    const body = root.querySelector('[data-chat-body]');
    const sendButton = root.querySelector('[data-chat-send]');
    const chips = root.querySelectorAll('[data-chat-chip]');
    const endpoint = root.dataset.chatEndpoint || '/ai-chat';

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

    function appendMessage(text, owner) {
        if (!messages || !text.trim()) return;
        const item = document.createElement('div');
        item.className = 'hipzi-chat__message hipzi-chat__message--' + owner;
        item.innerHTML = '<div class="hipzi-chat__bubble"></div><span class="hipzi-chat__time"></span>';
        item.querySelector('.hipzi-chat__bubble').textContent = text;
        item.querySelector('.hipzi-chat__time').textContent = currentTime();
        messages.appendChild(item);
        scrollBottom();
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
            appendMessage(data.reply || 'Hipzi AI ch\\u01b0a c\\u00f3 ph\\u1ea3n h\\u1ed3i ph\\u00f9 h\\u1ee3p.', 'bot');
        } catch (error) {
            root.classList.remove('is-typing');
            appendMessage('Hipzi AI \\u0111ang b\\u1eadn m\\u1ed9t ch\\u00fat. B\\u1ea1n th\\u1eed l\\u1ea1i sau nh\\u00e9.', 'bot');
        }
    }

    launcher?.addEventListener('click', () => setOpen(!root.classList.contains('is-open')));
    closeButton?.addEventListener('click', () => setOpen(false));

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
