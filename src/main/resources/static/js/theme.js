(function() {
    function applyThemeImmediately() {
        const savedTheme = localStorage.getItem('theme') || 'dark';
        const html = document.documentElement;
        
                html.removeAttribute('data-theme');
        
                if (savedTheme !== 'dark') {
            html.setAttribute('data-theme', savedTheme);
        }
        
        return savedTheme;
    }

        applyThemeImmediately();

        function initTheme() {
        const savedTheme = localStorage.getItem('theme') || 'dark';
        updateThemeButtons(savedTheme);
        
                updateDiagramTooltip(savedTheme);
    }

        window.setTheme = function(theme) {
        const html = document.documentElement;
        
                html.removeAttribute('data-theme');
        
                if (theme !== 'dark') {
            html.setAttribute('data-theme', theme);
        }
        
                localStorage.setItem('theme', theme);
        
                updateThemeButtons(theme);
        
                updateDiagramTooltip(theme);
    };

        function updateThemeButtons(activeTheme) {
        const darkBtn = document.getElementById('darkThemeBtn');
        const lightBtn = document.getElementById('lightThemeBtn');
        
        if (darkBtn) {
            darkBtn.classList.toggle('active', activeTheme === 'dark');
        }
        
        if (lightBtn) {
            lightBtn.classList.toggle('active', activeTheme === 'light');
        }
    }

        function updateDiagramTooltip(theme) {
        const tooltip = document.querySelector('.diagram-tooltip');
        if (tooltip) {
            if (theme === 'light') {
                tooltip.style.background = 'rgba(255, 255, 255, 0.95)';
                tooltip.style.border = '1px solid var(--accent)';
            } else {
                tooltip.style.background = 'rgba(12,22,39,0.95)';
                tooltip.style.border = '1px solid var(--accent)';
            }
        }
    }

        if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTheme);
    } else {
        initTheme();
    }
})();
