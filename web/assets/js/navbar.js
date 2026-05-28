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
            { match: ['/exam-room'], target: '/exam-room' },
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
