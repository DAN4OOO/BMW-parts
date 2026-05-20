(function () {
    const theme = localStorage.getItem('theme') || 'dark';
    if (theme !== 'dark') document.documentElement.setAttribute('data-theme', theme);

    function markActive(t) {
        document.querySelectorAll('.theme-option').forEach(btn => {
            btn.classList.toggle('active', btn.id.startsWith(t));
        });
    }

    window.setTheme = function (t) {
        document.documentElement.removeAttribute('data-theme');
        if (t !== 'dark') document.documentElement.setAttribute('data-theme', t);
        localStorage.setItem('theme', t);
        markActive(t);
    };

    document.addEventListener('DOMContentLoaded', function () {
        markActive(theme);
    });
})();