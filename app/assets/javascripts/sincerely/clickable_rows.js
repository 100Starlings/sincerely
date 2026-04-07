(function() {
  document.addEventListener('click', function(e) {
    var row = e.target.closest('tr.clickable-row');
    if (!row || !row.dataset.href) return;
    if (e.target.closest('a, button, details, summary')) return;

    window.location = row.dataset.href;
  });

  document.addEventListener('keydown', function(e) {
    var row = e.target;
    if (!row.classList.contains('clickable-row')) return;

    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      if (row.dataset.href) window.location = row.dataset.href;
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      var next = row.nextElementSibling;
      while (next && !next.classList.contains('clickable-row')) next = next.nextElementSibling;
      if (next) next.focus();
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      var prev = row.previousElementSibling;
      while (prev && !prev.classList.contains('clickable-row')) prev = prev.previousElementSibling;
      if (prev) prev.focus();
    }
  });
})();
