document.querySelectorAll('.preview-tab').forEach(function(tab) {
  tab.addEventListener('click', function() {
    var selected = tab.dataset.tab;

    document.querySelectorAll('.preview-tab').forEach(function(t) {
      t.classList.toggle('active', t.dataset.tab === selected);
    });

    document.getElementById('html-preview').style.display = selected === 'html' ? 'block' : 'none';
    document.getElementById('text-preview').style.display = selected === 'text' ? 'block' : 'none';
  });
});
