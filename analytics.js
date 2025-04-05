function loadAnalytics() {
    const script = document.createElement('script');
    script.defer = true;
    script.setAttribute('data-website-id', '67f020e2d15427739c2f880a');
    script.setAttribute('data-domain', 'docs.cocartapi.com');
    script.src = 'https://datafa.st/js/script.js';
    document.head.appendChild(script);
}

// Execute when the DOM is fully loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadAnalytics);
} else {
    loadAnalytics();
}
