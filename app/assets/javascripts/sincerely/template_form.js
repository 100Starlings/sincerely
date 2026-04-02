(function() {
  function updateHtmlPreview() {
    const textarea = document.getElementById('html_content');
    const iframe = document.getElementById('html_preview');
    if (!textarea || !iframe) return;

    iframe.srcdoc = textarea.value || '';
  }

  function updateTextPreview() {
    const textarea = document.getElementById('text_content');
    const preview = document.getElementById('text_preview');
    if (!textarea || !preview) return;

    preview.textContent = textarea.value || '';
  }

  document.querySelectorAll('.preview-container').forEach(container => {
    const tabs = container.querySelectorAll('.preview-tab');
    const panels = container.querySelectorAll('.preview-panel');
    const previewType = container.dataset.preview;

    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const target = tab.dataset.target;

        tabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');

        panels.forEach(p => {
          p.classList.toggle('active', p.dataset.panel === target);
        });

        if (target === 'preview') {
          if (previewType === 'html') {
            updateHtmlPreview();
          } else if (previewType === 'text') {
            updateTextPreview();
          }
        }
      });
    });
  });
})();
