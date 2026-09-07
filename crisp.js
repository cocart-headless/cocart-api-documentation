function loadCrisp() {
    window.$crisp = [];
    window.CRISP_WEBSITE_ID = 'f8dbef48-338e-4d8d-98e3-62919a8a73ae';

    const script = document.createElement('script');
    script.async = true;
    script.src = 'https://client.crisp.chat/l.js';
    document.head.appendChild(script);
}

// Execute when the DOM is fully loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadCrisp);
} else {
    loadCrisp();
}
