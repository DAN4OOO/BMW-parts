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
    }

        window.setTheme = function(theme) {
        const html = document.documentElement;
        html.removeAttribute('data-theme');
        if (theme !== 'dark') {
            html.setAttribute('data-theme', theme);
        }
        localStorage.setItem('theme', theme);
        updateThemeButtons(theme);
    };

        function updateThemeButtons(activeTheme) {
        // Handle both authenticated and non-authenticated theme buttons
        const darkBtns = [
            document.getElementById('darkThemeBtn'),
            document.getElementById('darkThemeBtnAuth')
        ];
        const lightBtns = [
            document.getElementById('lightThemeBtn'),
            document.getElementById('lightThemeBtnAuth')
        ];
        
        darkBtns.forEach(btn => {
            if (btn) {
                btn.classList.toggle('active', activeTheme === 'dark');
            }
        });
        
        lightBtns.forEach(btn => {
            if (btn) {
                btn.classList.toggle('active', activeTheme === 'light');
            }
        });
    }

if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTheme);
    } else {
        initTheme();
    }
})();
