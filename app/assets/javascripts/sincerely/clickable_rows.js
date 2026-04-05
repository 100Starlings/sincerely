(function() {
  document.addEventListener('keydown', function(e) {
    if ((e.key === 'Enter' || e.key === ' ') && e.target.classList.contains('clickable-row')) {
      e.preventDefault();
      e.target.click();
    }
  });
})();
