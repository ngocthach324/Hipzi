/**
 * HIPZI Navbar Dynamic Scroll Behavior
 * Handles transparent to solid glassmorphic effect on scroll.
 */
const isIndexPage = /\/index\.jsp$/.test(window.location.pathname);
if (isIndexPage && 'scrollRestoration' in window.history) {
    window.history.scrollRestoration = 'manual';
}

function scrollIndexPageToTop() {
    if (!isIndexPage) return;
    window.scrollTo({ top: 0, left: 0, behavior: 'auto' });
}

scrollIndexPageToTop();
window.addEventListener('pageshow', scrollIndexPageToTop);
window.addEventListener('load', scrollIndexPageToTop);

document.addEventListener('DOMContentLoaded', function() {
    function prepareLetterTitle(title, charClass) {
        if (!title || title.dataset.animated === 'true') return;

        const text = title.textContent;
        const highlightText = title.dataset.highlightText || '';
        const accentText = title.dataset.accentText || '';
        const accentChar = title.dataset.accentChar || '';
        const accentMode = title.dataset.accentMode || '';
        const normalizedText = text.toLocaleLowerCase('vi-VN');
        const normalizedHighlight = highlightText.toLocaleLowerCase('vi-VN');
        const normalizedAccent = accentText.toLocaleLowerCase('vi-VN');
        const highlightStart = normalizedHighlight ? normalizedText.indexOf(normalizedHighlight) : -1;
        const highlightEnd = highlightStart + normalizedHighlight.length;
        const accentStart = normalizedAccent ? normalizedText.indexOf(normalizedAccent) : -1;
        const accentEnd = accentStart + normalizedAccent.length;
        title.dataset.animated = 'true';
        title.setAttribute('aria-label', text);
        title.textContent = '';

        let highlightGroup = null;

        Array.from(text).forEach((char, index) => {
            const isBrandBounceAccent = accentMode === 'brand-bounce' && accentStart >= 0 && index >= accentStart && index < accentEnd;
            if (isBrandBounceAccent) {
                if (index === accentStart) {
                    const brandDelay = (index * 22) + 260;
                    const brandStage = document.createElement('span');
                    brandStage.className = 'ai-title-brand-stage';
                    brandStage.setAttribute('aria-hidden', 'true');
                    brandStage.style.setProperty('--brand-delay', brandDelay + 'ms');

                    const brandText = document.createElement('span');
                    brandText.className = 'ai-title-brand-text';
                    brandText.textContent = text.slice(accentStart, accentEnd);
                    brandText.dataset.shineText = text.slice(accentStart, accentEnd);

                    brandStage.appendChild(brandText);
                    title.appendChild(brandStage);
                }
                return;
            }

            const isHighlighted = index >= highlightStart && index < highlightEnd;
            if (isHighlighted && !highlightGroup) {
                highlightGroup = document.createElement('span');
                highlightGroup.className = 'ecosystem-title-highlight-group';
                highlightGroup.dataset.highlightText = text.slice(highlightStart, highlightEnd);
                title.appendChild(highlightGroup);
            }

            const span = document.createElement('span');
            const classNames = [charClass];
            if (char === ' ') classNames.push('space');
            if (isHighlighted && char !== ' ') {
                classNames.push('highlight');
            }
            const isAccentChar = accentChar && char === accentChar;
            const isAccentRange = index >= accentStart && index < accentEnd;
            if ((isAccentChar || isAccentRange) && char !== ' ') {
                classNames.push('accent');
            }
            span.className = classNames.join(' ');
            span.textContent = char === ' ' ? '\u00A0' : char;
            span.style.setProperty('--letter-delay', (index * 22) + 'ms');
            span.setAttribute('aria-hidden', 'true');
            if (isHighlighted && highlightGroup) {
                highlightGroup.appendChild(span);
            } else {
                title.appendChild(span);
            }
        });
    }

    function prepareTypewriterText(textElement) {
        if (!textElement || textElement.dataset.animated === 'true') return;

        const text = textElement.textContent.trim();
        textElement.dataset.animated = 'true';
        textElement.setAttribute('aria-label', text);
        textElement.dataset.typewriterText = text;
        textElement.textContent = '';
    }

    function startTypewriterText(textElement) {
        if (!textElement || textElement.dataset.typed === 'true') return;

        const text = textElement.dataset.typewriterText || '';
        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        textElement.dataset.typed = 'true';

        if (prefersReducedMotion) {
            textElement.textContent = text;
            textElement.classList.add('typed');
            return;
        }

        let index = 0;
        const typeNextChar = () => {
            textElement.textContent = text.slice(0, index);
            index += 1;

            if (index <= text.length) {
                window.setTimeout(typeNextChar, 5);
            } else {
                textElement.classList.add('typed');
            }
        };

        typeNextChar();
    }

    prepareLetterTitle(document.querySelector('.ecosystem-title'), 'ecosystem-title-char');
    document.querySelectorAll('.scroll-letter-title').forEach(title => {
        prepareLetterTitle(title, 'scroll-letter-title-char');
    });
    document.querySelectorAll('.typewriter-text').forEach(prepareTypewriterText);

    const subjectTabs = Array.from(document.querySelectorAll('.subject-card[data-title]'));
    if (subjectTabs.length > 0) {
        const subjectTitle = document.getElementById('subjectTitle');
        const subjectDescription = document.getElementById('subjectDescription');
        const subjectFocus = document.getElementById('subjectFocus');
        const subjectClassCount = document.getElementById('subjectClassCount');
        const subjectMaterialCount = document.getElementById('subjectMaterialCount');
        const subjectQuizCount = document.getElementById('subjectQuizCount');
        const subjectCta = document.getElementById('subjectCta');
        const subjectPanel = document.querySelector('.subjects-panel');
        const subjectCardRow = document.querySelector('.subjects-card-row');
        const subjectPrevBtn = document.querySelector('.subjects-page-prev');
        const subjectNextBtn = document.querySelector('.subjects-page-next');
        const subjectPageSize = 4;
        let subjectPage = 0;
        let subjectDataTimer = null;
        let subjectTextTimer = null;
        let subjectCleanupTimer = null;

        const updateSubjectTextContent = tab => {
            if (subjectTitle) subjectTitle.textContent = tab.dataset.title || '';
            if (subjectDescription) subjectDescription.textContent = tab.dataset.description || '';
            if (subjectFocus) subjectFocus.textContent = tab.dataset.focus || '';
            if (subjectCta && tab.dataset.href) subjectCta.href = tab.dataset.href;
        };

        const updateSubjectMetricContent = tab => {
            if (subjectClassCount) subjectClassCount.textContent = tab.dataset.classCount || '0';
            if (subjectMaterialCount) subjectMaterialCount.textContent = tab.dataset.materialCount || '0';
            if (subjectQuizCount) subjectQuizCount.textContent = tab.dataset.quizCount || '0';
        };

        const updateSubjectPanelContent = tab => {
            updateSubjectTextContent(tab);
            updateSubjectMetricContent(tab);
        };

        const refreshSubjectPanel = (tab, direction = 'forward') => {
            const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
            const isBackward = direction === 'backward';

            if (subjectDataTimer) window.clearTimeout(subjectDataTimer);
            if (subjectTextTimer) window.clearTimeout(subjectTextTimer);
            if (subjectCleanupTimer) window.clearTimeout(subjectCleanupTimer);

            if (!subjectPanel || prefersReducedMotion) {
                updateSubjectPanelContent(tab);
                if (subjectPanel) {
                    subjectPanel.classList.remove('is-switching');
                    window.requestAnimationFrame(() => subjectPanel.classList.add('is-switching'));
                }
                return;
            }

            subjectPanel.classList.remove('is-switching', 'is-page-flipping', 'is-flip-forward', 'is-flip-backward', 'is-metric-ready', 'is-text-ready');
            void subjectPanel.offsetWidth;
            subjectPanel.classList.add('is-page-flipping', isBackward ? 'is-flip-backward' : 'is-flip-forward');

            subjectDataTimer = window.setTimeout(() => {
                if (isBackward) {
                    updateSubjectTextContent(tab);
                    subjectPanel.classList.add('is-text-ready');
                } else {
                    updateSubjectMetricContent(tab);
                    subjectPanel.classList.add('is-metric-ready');
                }
            }, 760);

            subjectTextTimer = window.setTimeout(() => {
                if (isBackward) {
                    updateSubjectMetricContent(tab);
                    subjectPanel.classList.add('is-metric-ready');
                } else {
                    updateSubjectTextContent(tab);
                    subjectPanel.classList.add('is-text-ready');
                }
            }, 980);

            subjectCleanupTimer = window.setTimeout(() => {
                subjectPanel.classList.remove('is-page-flipping', 'is-flip-forward', 'is-flip-backward', 'is-metric-ready', 'is-text-ready');
            }, 1500);
        };

        const selectSubjectTab = tab => {
            if (tab.classList.contains('active')) return;

            const currentIndex = subjectTabs.findIndex(item => item.classList.contains('active'));
            const nextIndex = subjectTabs.indexOf(tab);
            const direction = currentIndex >= 0 && nextIndex < currentIndex ? 'backward' : 'forward';

            subjectTabs.forEach(item => {
                item.classList.remove('active');
                item.setAttribute('aria-selected', 'false');
            });

            tab.classList.add('active');
            tab.setAttribute('aria-selected', 'true');

            refreshSubjectPanel(tab, direction);
        };

        const updateSubjectPage = (nextPage, animateDirection = 0) => {
            const pageCount = Math.ceil(subjectTabs.length / subjectPageSize);
            subjectPage = Math.max(0, Math.min(nextPage, pageCount - 1));
            const start = subjectPage * subjectPageSize;
            const end = start + subjectPageSize;

            if (subjectCardRow && animateDirection !== 0) {
                subjectCardRow.classList.remove('slide-left', 'slide-right');
                void subjectCardRow.offsetWidth;
                subjectCardRow.classList.add(animateDirection > 0 ? 'slide-left' : 'slide-right');
            }

            subjectTabs.forEach((tab, index) => {
                tab.classList.toggle('is-hidden', index < start || index >= end);
            });

            if (subjectPrevBtn) subjectPrevBtn.disabled = subjectPage === 0;
            if (subjectNextBtn) subjectNextBtn.disabled = subjectPage >= pageCount - 1;
        };

        subjectTabs.forEach(tab => {
            tab.addEventListener('click', () => {
                selectSubjectTab(tab);
            });
        });

        if (subjectPrevBtn) {
            subjectPrevBtn.addEventListener('click', () => updateSubjectPage(subjectPage - 1, -1));
        }

        if (subjectNextBtn) {
            subjectNextBtn.addEventListener('click', () => updateSubjectPage(subjectPage + 1, 1));
        }

        updateSubjectPage(0);
    }

    const navLinks = document.querySelectorAll('.nav-links a[href]');
    if (navLinks.length > 0) {
        const currentPath = window.location.pathname.replace(/\/+$/, '');
        const indexLink = Array.from(navLinks).find(link => {
            const linkPath = new URL(link.href, window.location.origin).pathname.replace(/\/+$/, '');
            return linkPath.endsWith('/index.jsp');
        });
        const appRoot = indexLink
            ? new URL(indexLink.href, window.location.origin).pathname.replace(/\/index\.jsp$/, '').replace(/\/+$/, '')
            : '';
        const activeGroups = [
            { match: ['/material-repository'], target: '/material-repository' },
            { match: ['/classes', '/class-detail', '/classroom'], target: '/classes' },
            { match: ['/practice'], target: '/practice' },
            { match: ['/exam-room', '/class-exam-room', '/class-exam-room.jsp'], target: '/exam-room' },
            { match: ['/teachers'], target: '/teachers' }
        ];

        const activeGroup = activeGroups.find(group =>
            group.match.some(path => currentPath.endsWith(path))
        );

        navLinks.forEach(link => {
            const linkUrl = new URL(link.href, window.location.origin);
            const linkPath = linkUrl.pathname.replace(/\/+$/, '');
            const isHome = !activeGroup && linkPath.endsWith('/index.jsp')
                    && !link.hash
                    && (currentPath === appRoot || currentPath.endsWith('/index.jsp'));
            const isActive = isHome || (!!activeGroup && linkPath.endsWith(activeGroup.target));
            link.classList.toggle('active', isActive);
        });

        setTimeout(() => {
            const navContainer = document.querySelector('.nav-links');
            if (navContainer) navContainer.classList.add('navbar-ready');
        }, 50);
    }

    const avatarDropdowns = Array.from(document.querySelectorAll('.nav-avatar-dropdown'))
        .filter(dropdown => dropdown.id !== 'teacherAvatarDropdown');
    if (avatarDropdowns.length > 0) {
        const closeAvatarMenus = exceptDropdown => {
            avatarDropdowns.forEach(dropdown => {
                if (dropdown === exceptDropdown) return;
                dropdown.classList.remove('is-open');
                const trigger = dropdown.querySelector('.nav-avatar-frame');
                if (trigger) trigger.setAttribute('aria-expanded', 'false');
            });
        };

        avatarDropdowns.forEach(dropdown => {
            const trigger = dropdown.querySelector('.nav-avatar-frame');
            if (!trigger) return;
            if (!trigger.hasAttribute('aria-haspopup')) {
                trigger.setAttribute('aria-haspopup', 'true');
            }
            trigger.setAttribute('aria-expanded', 'false');

            trigger.addEventListener('click', event => {
                event.preventDefault();
                event.stopPropagation();
                const willOpen = !dropdown.classList.contains('is-open');
                closeAvatarMenus(dropdown);
                dropdown.classList.toggle('is-open', willOpen);
                trigger.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
            });

            dropdown.addEventListener('click', event => {
                event.stopPropagation();
            });
        });

        document.addEventListener('click', () => closeAvatarMenus());
        document.addEventListener('keydown', event => {
            if (event.key === 'Escape') closeAvatarMenus();
        });
    }

    window.addEventListener('scroll', function() {
        const navbar = document.querySelector('.navbar');
        if (navbar) {
            if (window.scrollY > 20) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        }
    });

    // Scroll Animation Observer for Feature Cards and Titles (Standard Threshold)
    const generalElements = document.querySelectorAll('.ecosystem-title, .scroll-letter-title, .typewriter-text, .feature-card, .ai-roadmap-step');
    if (generalElements.length > 0 && 'IntersectionObserver' in window) {
        const observer = new IntersectionObserver((entries, observerInstance) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                    if (entry.target.classList.contains('typewriter-text')) {
                        startTypewriterText(entry.target);
                    }
                    observerInstance.unobserve(entry.target);
                }
            });
        }, { threshold: 0.15 });

        generalElements.forEach(el => {
            observer.observe(el);
        });
    } else if (generalElements.length > 0) {
        generalElements.forEach(el => {
            el.classList.add('animate');
            if (el.classList.contains('typewriter-text')) {
                startTypewriterText(el);
            }
        });
    }

    const subjectsPanelReveal = document.querySelector('.subjects-panel');
    const subjectsCardReveal = document.querySelector('.subjects-card-shell');
    if (subjectsPanelReveal && 'IntersectionObserver' in window) {
        const subjectsRevealObserver = new IntersectionObserver((entries, observerInstance) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    subjectsPanelReveal.classList.add('subjects-content-visible');
                    if (subjectsCardReveal) {
                        subjectsCardReveal.classList.add('subjects-content-visible');
                    }
                    observerInstance.unobserve(entry.target);
                }
            });
        }, { threshold: 0.3 });

        subjectsRevealObserver.observe(subjectsPanelReveal);
    } else if (subjectsPanelReveal) {
        subjectsPanelReveal.classList.add('subjects-content-visible');
        if (subjectsCardReveal) {
            subjectsCardReveal.classList.add('subjects-content-visible');
        }
    }

    // Scroll Animation Observer for Contact Form and QR Cards
    const contactElements = document.querySelectorAll('.contact-left-col, .contact-right-col');
    if (contactElements.length > 0 && 'IntersectionObserver' in window) {
        const contactObserver = new IntersectionObserver((entries, observerInstance) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                    observerInstance.unobserve(entry.target);
                }
            });
        }, { threshold: 0.25 });

        contactElements.forEach(el => {
            contactObserver.observe(el);
        });
    } else if (contactElements.length > 0) {
        contactElements.forEach(el => el.classList.add('animate'));
    }

    const hipziHowSection = document.querySelector('.hipzi-how-section');
    if (hipziHowSection) {
        const howStage = hipziHowSection.querySelector('.hipzi-how-stage');
        const howScene = hipziHowSection.querySelector('.hipzi-how-scene');
        const howCards = Array.from(hipziHowSection.querySelectorAll('[data-hipzi-how-card]'));
        const howCarouselItems = Array.from(hipziHowSection.querySelectorAll('.hipzi-how-carousel-item'));
        const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
        const mobileQuery = window.matchMedia('(max-width: 768px)');
        let activeHowIndex = -1;
        let hipziHowTicking = false;

        const clamp = (value, min, max) => Math.min(Math.max(value, min), max);

        const setHipziHowActive = index => {
            activeHowIndex = Math.max(-1, Math.min(index, howCards.length - 1));

            if (activeHowIndex === -1) {
                hipziHowSection.dataset.activeStep = "0";
                hipziHowSection.dataset.activeSide = "left";
            } else {
                const activeCard = howCards[activeHowIndex];
                const side = activeCard?.dataset.side || (activeHowIndex % 2 === 0 ? 'left' : 'right');
                hipziHowSection.dataset.activeStep = String(activeHowIndex + 1);
                hipziHowSection.dataset.activeSide = side;
            }

            howCards.forEach((card, cardIndex) => {
                card.classList.toggle('is-active', cardIndex === activeHowIndex);
                card.classList.toggle('is-previous', cardIndex === activeHowIndex - 1);
                card.classList.toggle('is-visible', cardIndex < activeHowIndex);
            });

            // Giữ cho ảnh active trong carousel luôn hiển thị step 1 (index 0) làm mặc định khi chưa bắt đầu scroll
            const displayActiveIndex = activeHowIndex < 0 ? 0 : activeHowIndex;

            howCarouselItems.forEach((item, itemIndex) => {
                item.classList.toggle('is-active', itemIndex === displayActiveIndex);
            });
        };

        const updateHipziHowByScroll = () => {
            hipziHowTicking = false;

            if (!howStage || !howScene || howCards.length === 0) return;

            const stageRect = howStage.getBoundingClientRect();
            const stageHeight = howStage.offsetHeight;
            const sceneHeight = howScene.offsetHeight;
            const maxSceneY = Math.max(1, stageHeight - sceneHeight);
            const centeredSceneY = window.innerHeight * 0.5 - stageRect.top - sceneHeight * 0.5;
            const sceneY = mobileQuery.matches ? 0 : clamp(centeredSceneY, 0, maxSceneY);

            hipziHowSection.style.setProperty('--scene-y', `${sceneY.toFixed(1)}px`);

            // Chỉ kích hoạt các card khi section đã cuộn vào viewport
            if (stageRect.top > window.innerHeight) return;

            // Tính toán tiến trình cuộn tổng thể của section (từ 0 đến 1)
            const overallProgress = mobileQuery.matches
                ? clamp((window.innerHeight * 0.62 - stageRect.top) / Math.max(1, stageHeight), 0, 1)
                : (centeredSceneY > 0 ? clamp(centeredSceneY / maxSceneY, 0, 1) : 0);

            // Cập nhật thuộc tính --card-progress riêng biệt cho mỗi card dựa trên tiến trình cuộn phân đoạn
            howCards.forEach((card, cardIndex) => {
                let cardProgress = 0;
                if (cardIndex === 0) {
                    cardProgress = clamp(overallProgress / 0.13, 0, 1);
                } else if (cardIndex === 1) {
                    cardProgress = overallProgress > 0.13 ? clamp((overallProgress - 0.13) / 0.23, 0, 1) : 0;
                } else if (cardIndex === 2) {
                    cardProgress = overallProgress > 0.40 ? clamp((overallProgress - 0.40) / 0.23, 0, 1) : 0;
                } else if (cardIndex === 3) {
                    cardProgress = overallProgress > 0.67 ? clamp((overallProgress - 0.67) / 0.23, 0, 1) : 0;
                }
                card.style.setProperty('--card-progress', cardProgress.toFixed(3));
            });

            // Tính toán góc quay của carousel dựa trên tiến trình phân đoạn
            let carouselAngle = 0;
            if (overallProgress <= 0.13) {
                carouselAngle = 0;
            } else if (overallProgress <= 0.36) {
                const t = (overallProgress - 0.13) / 0.23;
                carouselAngle = t * -90;
            } else if (overallProgress <= 0.40) {
                carouselAngle = -90;
            } else if (overallProgress <= 0.63) {
                const t = (overallProgress - 0.40) / 0.23;
                carouselAngle = -90 + t * -90;
            } else if (overallProgress <= 0.67) {
                carouselAngle = -180;
            } else if (overallProgress <= 0.90) {
                const t = (overallProgress - 0.67) / 0.23;
                carouselAngle = -180 + t * -90;
            } else {
                carouselAngle = -270;
            }
            hipziHowSection.style.setProperty('--carousel-angle', `${carouselAngle.toFixed(1)}deg`);

            // Tính toán độ mờ (opacity) và thứ tự hiển thị (z-index) cho từng ảnh trong carousel
            howCarouselItems.forEach((item, itemIndex) => {
                const localAngle = itemIndex * 90;
                const relativeAngle = localAngle + carouselAngle;
                
                // Chuẩn hóa góc về khoảng [-180, 180]
                let normalizedAngle = ((relativeAngle + 180) % 360) - 180;
                if (normalizedAngle < -180) normalizedAngle += 360;
                
                const distanceToFront = Math.abs(normalizedAngle);
                let itemOpacity = 0;
                
                if (distanceToFront < 90) {
                    itemOpacity = 1 - (distanceToFront / 90); // Giảm từ 1 về 0 khi lệch góc
                } else {
                    itemOpacity = 0; // Hoàn toàn ẩn khi ở phía sau hoặc bên cạnh
                }
                
                item.style.setProperty('--item-opacity', itemOpacity.toFixed(3));
                item.style.zIndex = Math.round(itemOpacity * 20);
            });

            // Xác định bước active hiện tại để đổi trạng thái
            let nextIndex = -1;
            if (overallProgress > 0) {
                if (overallProgress <= 0.13) {
                    nextIndex = 0;
                } else if (overallProgress <= 0.40) {
                    nextIndex = 1;
                } else if (overallProgress <= 0.67) {
                    nextIndex = 2;
                } else {
                    nextIndex = 3;
                }
            }

            setHipziHowActive(nextIndex);
        };

        const requestHipziHowUpdate = () => {
            if (hipziHowTicking) return;
            hipziHowTicking = true;
            window.requestAnimationFrame(updateHipziHowByScroll);
        };

        updateHipziHowByScroll();
        window.addEventListener('scroll', requestHipziHowUpdate, { passive: true });
        window.addEventListener('resize', requestHipziHowUpdate);

        if (typeof prefersReducedMotion.addEventListener === 'function') {
            prefersReducedMotion.addEventListener('change', requestHipziHowUpdate);
            mobileQuery.addEventListener('change', requestHipziHowUpdate);
        }
    }
});

(function () {
    'use strict';

    function shouldSkip(select) {
        return !select
            || select.dataset.hipziSelectEnhanced === 'true'
            || select.matches('[data-native-select], .hipzi-select-native, .exam-mode-native')
            || select.multiple
            || select.size > 1;
    }

    function closeSelect(wrapper) {
        if (!wrapper) return;
        wrapper.classList.remove('is-open');
        var trigger = wrapper.querySelector('.hipzi-select-trigger');
        if (trigger) trigger.setAttribute('aria-expanded', 'false');
    }

    function closeAll(exceptWrapper) {
        document.querySelectorAll('.hipzi-select.is-open').forEach(function (wrapper) {
            if (wrapper !== exceptWrapper) closeSelect(wrapper);
        });
    }

    function syncSelect(select) {
        if (!select || select.dataset.hipziSelectEnhanced !== 'true') return;
        var wrapper = select.closest('.hipzi-select');
        if (!wrapper) return;
        var selectedOption = select.options[select.selectedIndex];
        var label = wrapper.querySelector('.hipzi-select-label');
        if (label) label.textContent = selectedOption ? selectedOption.textContent : '';
        wrapper.classList.toggle('is-disabled', select.disabled);
        var trigger = wrapper.querySelector('.hipzi-select-trigger');
        if (trigger) trigger.disabled = select.disabled;
        wrapper.querySelectorAll('.hipzi-select-option').forEach(function (optionButton) {
            var selected = optionButton.dataset.value === select.value;
            optionButton.classList.toggle('is-selected', selected);
            optionButton.setAttribute('aria-selected', selected ? 'true' : 'false');
        });
    }

    function renderOptions(select) {
        var wrapper = select.closest('.hipzi-select');
        var menu = wrapper ? wrapper.querySelector('.hipzi-select-menu') : null;
        if (!menu) return;
        menu.innerHTML = '';
        Array.from(select.options).forEach(function (option) {
            var optionButton = document.createElement('button');
            optionButton.type = 'button';
            optionButton.className = 'hipzi-select-option';
            optionButton.dataset.value = option.value;
            optionButton.setAttribute('role', 'option');
            optionButton.disabled = option.disabled;

            var optionLabel = document.createElement('span');
            optionLabel.textContent = option.textContent;
            var optionCheck = document.createElement('span');
            optionCheck.className = 'hipzi-select-check';
            optionCheck.setAttribute('aria-hidden', 'true');
            optionCheck.textContent = '\u2713';
            optionButton.append(optionLabel, optionCheck);
            optionButton.addEventListener('click', function () {
                if (option.disabled) return;
                select.value = option.value;
                wrapper.classList.remove('is-invalid');
                syncSelect(select);
                closeAll();
                select.dispatchEvent(new Event('change', { bubbles: true }));
            });
            menu.appendChild(optionButton);
        });
        syncSelect(select);
    }

    function enhanceSelect(select) {
        if (shouldSkip(select)) return;
        var selectRect = select.getBoundingClientRect();
        var parentRect = select.parentElement ? select.parentElement.getBoundingClientRect() : null;
        var shouldFill = select.style.width === '100%'
            || (parentRect && parentRect.width > 0 && selectRect.width >= parentRect.width * 0.9);

        var wrapper = document.createElement('div');
        wrapper.className = 'hipzi-select';
        if (shouldFill) {
            wrapper.classList.add('hipzi-select--fill');
        } else if (selectRect.width > 0) {
            wrapper.style.minWidth = Math.round(selectRect.width) + 'px';
        }

        var trigger = document.createElement('button');
        trigger.type = 'button';
        trigger.className = 'hipzi-select-trigger';
        trigger.setAttribute('aria-haspopup', 'listbox');
        trigger.setAttribute('aria-expanded', 'false');

        var label = document.createElement('span');
        label.className = 'hipzi-select-label';
        var svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('viewBox', '0 0 20 20');
        svg.setAttribute('fill', 'none');
        svg.setAttribute('stroke', 'currentColor');
        svg.setAttribute('stroke-width', '2');
        svg.setAttribute('aria-hidden', 'true');
        var path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
        path.setAttribute('d', 'm5 7.5 5 5 5-5');
        svg.appendChild(path);
        trigger.append(label, svg);

        var menu = document.createElement('div');
        menu.className = 'hipzi-select-menu';
        menu.setAttribute('role', 'listbox');
        menu.setAttribute('aria-label', select.getAttribute('aria-label') || select.name || 'T\u00f9y ch\u1ecdn');

        select.parentNode.insertBefore(wrapper, select);
        wrapper.append(select, trigger, menu);
        select.dataset.hipziSelectEnhanced = 'true';
        select.classList.add('hipzi-select-native');
        select.setAttribute('aria-hidden', 'true');
        select.tabIndex = -1;

        trigger.addEventListener('click', function () {
            var willOpen = !wrapper.classList.contains('is-open');
            closeAll(wrapper);
            wrapper.classList.toggle('is-open', willOpen);
            trigger.setAttribute('aria-expanded', willOpen ? 'true' : 'false');
        });
        trigger.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                closeSelect(wrapper);
                return;
            }
            if (event.key !== 'ArrowDown' && event.key !== 'ArrowUp') return;
            event.preventDefault();
            closeAll(wrapper);
            wrapper.classList.add('is-open');
            trigger.setAttribute('aria-expanded', 'true');
            var selected = menu.querySelector('.is-selected') || menu.querySelector('.hipzi-select-option');
            if (selected) selected.focus();
        });
        menu.addEventListener('keydown', function (event) {
            var options = Array.from(menu.querySelectorAll('.hipzi-select-option:not(:disabled)'));
            var index = options.indexOf(document.activeElement);
            if (event.key === 'Escape') {
                closeSelect(wrapper);
                trigger.focus();
            } else if ((event.key === 'ArrowDown' || event.key === 'ArrowUp') && options.length) {
                event.preventDefault();
                var offset = event.key === 'ArrowDown' ? 1 : -1;
                options[(index + offset + options.length) % options.length].focus();
            }
        });
        select.addEventListener('change', function () {
            wrapper.classList.remove('is-invalid');
            syncSelect(select);
        });
        select.addEventListener('invalid', function () {
            wrapper.classList.add('is-invalid');
            trigger.focus();
        });
        renderOptions(select);
    }

    function enhanceTree(root) {
        if (!root) return;
        if (root.matches && root.matches('select')) enhanceSelect(root);
        if (root.querySelectorAll) root.querySelectorAll('select').forEach(enhanceSelect);
    }

    function init() {
        enhanceTree(document);
        document.addEventListener('click', function (event) {
            if (!event.target.closest('.hipzi-select')) closeAll();
        });
        new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                mutation.addedNodes.forEach(function (node) {
                    if (node.nodeType === Node.ELEMENT_NODE) enhanceTree(node);
                });
            });
        }).observe(document.body, { childList: true, subtree: true });
    }

    window.HipziSelect = {
        enhance: enhanceSelect,
        refresh: function (select) {
            if (!select) return;
            if (select.dataset.hipziSelectEnhanced !== 'true') enhanceSelect(select);
            renderOptions(select);
        },
        refreshAll: function () {
            enhanceTree(document);
        }
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
