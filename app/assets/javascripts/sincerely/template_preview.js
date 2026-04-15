document.querySelectorAll('.preview-tab').forEach(function(tab) {
  tab.addEventListener('click', function() {
    var selected = tab.dataset.tab;

    document.querySelectorAll('.preview-tab').forEach(function(t) {
      t.classList.toggle('active', t.dataset.tab === selected);
    });

    document.getElementById('html-preview').classList.toggle('preview-frame--hidden', selected !== 'html');
    document.getElementById('text-preview').classList.toggle('preview-frame--hidden', selected !== 'text');
  });
});
