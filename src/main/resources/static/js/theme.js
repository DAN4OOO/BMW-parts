// Theme Switching Functionality
(function() {
    // Apply theme immediately to prevent FOUC
    function applyThemeImmediately() {
        const savedTheme = localStorage.getItem('theme') || 'dark';
        const html = document.documentElement;
        
        // Remove existing theme attribute
        html.removeAttribute('data-theme');
        
        // Set new theme if not dark
        if (savedTheme !== 'dark') {
            html.setAttribute('data-theme', savedTheme);
        }
        
        return savedTheme;
    }

    // Apply theme immediately before DOM loads
    applyThemeImmediately();

    // Initialize theme on page load
    function initTheme() {
        const savedTheme = localStorage.getItem('theme') || 'dark';
        updateThemeButtons(savedTheme);
        
        // Update diagram tooltip background for light theme
        updateDiagramTooltip(savedTheme);
    }

    // Set theme function
    window.setTheme = function(theme) {
        const html = document.documentElement;
        
        // Remove existing theme attribute
        html.removeAttribute('data-theme');
        
        // Set new theme if not dark
        if (theme !== 'dark') {
            html.setAttribute('data-theme', theme);
        }
        
        // Save to localStorage
        localStorage.setItem('theme', theme);
        
        // Update button states
        updateThemeButtons(theme);
        
        // Update diagram tooltip background for light theme
        updateDiagramTooltip(theme);
    };

    // Update theme button states
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

    // Update diagram tooltip background based on theme
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

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTheme);
    } else {
        initTheme();
    }
})();
