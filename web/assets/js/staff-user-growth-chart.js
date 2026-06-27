(function () {
    const rawData = window.HipziStaffUserGrowthData || { week: [], month: [] };
    let activePeriod = 'week';

    function buildChart(points) {
        const safePoints = (points && points.length ? points : [{ label: '', fullLabel: '', count: 0, countLabel: '0 tài khoản' }]).slice(0, 7);
        while (safePoints.length < 7) {
            safePoints.push({ label: '', fullLabel: '', count: 0, countLabel: '0 tài khoản' });
        }

        const maxCount = Math.max(1, ...safePoints.map(point => Number(point.count) || 0));
        const chartLeft = 64;
        const chartRight = 610;
        const chartBottom = 162;
        const chartTop = 24;
        const chartWidth = chartRight - chartLeft;
        const chartHeight = chartBottom - chartTop;
        const coords = safePoints.map((point, index) => {
            const value = Number(point.count) || 0;
            const x = chartLeft + (chartWidth / 6) * index;
            const y = chartBottom - Math.min(1, value / maxCount) * chartHeight;
            return { x, y, point };
        });

        return {
            ticks: safePoints.map(point => point.label || ''),
            points: coords.map(coord => ({
                x: coord.x,
                y: coord.y,
                label: coord.point.label || '',
                fullLabel: coord.point.fullLabel || coord.point.label || '',
                countLabel: coord.point.countLabel || '0 tài khoản'
            })),
            total: safePoints.reduce((sum, point) => sum + (Number(point.count) || 0), 0),
            yLabels: [
                String(maxCount),
                String(Math.ceil(maxCount * 2 / 3)),
                String(Math.ceil(maxCount / 3)),
                '0'
            ],
            line: coords.map((coord, index) => (index === 0 ? 'M' : 'L') + coord.x.toFixed(1) + ' ' + coord.y.toFixed(1)).join(' ')
        };
    }

    const charts = {
        week: buildChart(rawData.week),
        month: buildChart(rawData.month)
    };

    function updateTooltip(data, index) {
        if (!data || !data.points || !data.points.length) return;
        const safeIndex = Math.max(0, Math.min(data.points.length - 1, index));
        const point = data.points[safeIndex];
        const tooltipDate = document.getElementById('staffUserGrowthTooltipDate');
        const tooltipValue = document.getElementById('staffUserGrowthTooltipValue');
        const guideLine = document.getElementById('staffUserGrowthGuideLine');
        const dot = document.getElementById('staffUserGrowthDot');
        const tooltip = document.getElementById('staffUserGrowthTooltip');

        if (tooltipDate) tooltipDate.textContent = point.fullLabel || point.label || '';
        if (tooltipValue) tooltipValue.textContent = point.countLabel || '0 tài khoản';
        if (guideLine) {
            guideLine.setAttribute('x1', point.x.toFixed(1));
            guideLine.setAttribute('x2', point.x.toFixed(1));
        }
        if (dot) {
            dot.setAttribute('cx', point.x.toFixed(1));
            dot.setAttribute('cy', point.y.toFixed(1));
        }
        if (tooltip) {
            tooltip.style.left = Math.max(18, Math.min(82, (point.x / 640) * 100)).toFixed(1) + '%';
        }
    }

    function renderChart(period) {
        const data = charts[period] || charts.week;
        const switchEl = document.getElementById('staffUserGrowthPeriodSwitch');
        if (!data || !switchEl) return;

        activePeriod = period;
        switchEl.dataset.active = period;
        switchEl.querySelectorAll('.overview-period-btn').forEach(button => {
            const isActive = button.dataset.period === period;
            button.classList.toggle('is-active', isActive);
            button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
        });

        data.ticks.forEach((label, index) => {
            const tick = document.getElementById('staffUserGrowthTick' + (index + 1));
            if (tick) tick.textContent = label;
        });
        data.yLabels.forEach((label, index) => {
            const axis = document.getElementById('staffUserGrowthY' + (4 - index));
            if (axis) axis.textContent = label;
        });

        const line = document.getElementById('staffUserGrowthLine');
        const area = document.getElementById('staffUserGrowthArea');
        const total = document.getElementById('staffUserGrowthTotal');
        if (line) line.setAttribute('d', data.line);
        if (area) area.setAttribute('d', data.line + ' L610 162 L64 162 Z');
        if (total) total.textContent = String(data.total);
        updateTooltip(data, data.points.length - 1);
    }

    window.initStaffUserGrowthChart = function () {
        const switchEl = document.getElementById('staffUserGrowthPeriodSwitch');
        const chartSvg = document.getElementById('staffUserGrowthChart');
        if (!switchEl || !chartSvg) return;

        switchEl.querySelectorAll('.overview-period-btn').forEach(button => {
            button.addEventListener('click', () => {
                if (!button.classList.contains('is-active')) {
                    renderChart(button.dataset.period);
                }
            });
        });

        chartSvg.addEventListener('mousemove', event => {
            const data = charts[activePeriod] || charts.week;
            if (!data || !data.points || !data.points.length) return;
            const rect = chartSvg.getBoundingClientRect();
            const mouseX = ((event.clientX - rect.left) / Math.max(1, rect.width)) * 640;
            let closestIndex = 0;
            let closestDistance = Number.POSITIVE_INFINITY;
            data.points.forEach((point, index) => {
                const distance = Math.abs(point.x - mouseX);
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closestIndex = index;
                }
            });
            updateTooltip(data, closestIndex);
        });

        chartSvg.addEventListener('mouseleave', () => {
            const data = charts[activePeriod] || charts.week;
            updateTooltip(data, data && data.points ? data.points.length - 1 : 0);
        });

        renderChart(switchEl.dataset.active || 'week');
    };
})();
