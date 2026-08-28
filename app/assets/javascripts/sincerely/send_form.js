(function() {
  const MAX_RECIPIENTS = 50;
  let recipients = [];

  const tagsContainer = document.getElementById('tagsContainer');
  const tagsList = document.getElementById('tagsList');
  const recipientInput = document.getElementById('recipientInput');
  const recipientsCount = document.getElementById('recipientsCount');
  const templateSelect = document.getElementById('templateSelect');
  const templateVariables = document.getElementById('templateVariables');
  const variablesGrid = document.getElementById('variablesGrid');
  const sendButton = document.getElementById('sendButton');
  const sendOverlay = document.getElementById('sendOverlay');
  const sendResult = document.getElementById('sendResult');
  const resultSuccess = document.getElementById('resultSuccess');
  const resultPartial = document.getElementById('resultPartial');
  const resultMessage = document.getElementById('resultMessage');
  const resetButton = document.getElementById('resetButton');
  const sendForm = document.querySelector('.send-form');

  function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+$/.test(email);
  }

  function addRecipient(email) {
    email = email.trim().toLowerCase();
    if (!email || recipients.includes(email) || recipients.length >= MAX_RECIPIENTS) return false;

    recipients.push(email);
    renderTags();
    updateCount();
    updateSendButton();
    return true;
  }

  function removeRecipient(email) {
    recipients = recipients.filter(r => r !== email);
    renderTags();
    updateCount();
    updateSendButton();
  }

  function renderTags() {
    tagsList.innerHTML = recipients.map(email => `
      <span class="tag ${isValidEmail(email) ? '' : 'invalid'}">
        ${escapeHtml(email)}
        <button type="button" class="tag-remove" data-email="${escapeHtml(email)}">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 6L6 18M6 6l12 12"></path>
          </svg>
        </button>
      </span>
    `).join('');

    tagsList.querySelectorAll('.tag-remove').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        removeRecipient(btn.dataset.email);
      });
    });
  }

  function updateCount() {
    const count = recipients.length;
    recipientsCount.textContent = `${count} / ${MAX_RECIPIENTS} recipients`;
    recipientsCount.className = 'recipients-count';
    if (count >= MAX_RECIPIENTS) {
      recipientsCount.classList.add('limit');
    } else if (count >= 40) {
      recipientsCount.classList.add('warning');
    }
  }

  function updateSendButton() {
    const hasRecipients = recipients.filter(isValidEmail).length > 0;
    const hasTemplate = templateSelect.value !== '';
    sendButton.disabled = !hasRecipients || !hasTemplate;
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function parseAndAddEmails(input) {
    const emails = input.split(/[\s,;]+/).filter(e => e.trim());
    emails.forEach(addRecipient);
  }

  // Input handlers
  recipientInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ',' || e.key === ' ' || e.key === 'Tab') {
      e.preventDefault();
      const value = recipientInput.value.trim();
      if (value) {
        parseAndAddEmails(value);
        recipientInput.value = '';
      }
    } else if (e.key === 'Backspace' && !recipientInput.value && recipients.length) {
      removeRecipient(recipients[recipients.length - 1]);
    }
  });

  recipientInput.addEventListener('paste', (e) => {
    e.preventDefault();
    const pastedText = e.clipboardData.getData('text');
    parseAndAddEmails(pastedText);
    recipientInput.value = '';
  });

  recipientInput.addEventListener('blur', () => {
    const value = recipientInput.value.trim();
    if (value) {
      parseAndAddEmails(value);
      recipientInput.value = '';
    }
  });

  tagsContainer.addEventListener('click', () => {
    recipientInput.focus();
  });

  // Template selection
  templateSelect.addEventListener('change', async () => {
    updateSendButton();

    const templateId = templateSelect.value;
    if (!templateId) {
      templateVariables.style.display = 'none';
      return;
    }

    try {
      const variablesUrl = document.getElementById('templateVariablesUrl').dataset.url.replace(':id', templateId);
      const response = await fetch(variablesUrl);
      const data = await response.json();

      if (data.variables && data.variables.length > 0) {
        variablesGrid.innerHTML = data.variables.map(v => {
          const label = v.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
          return `
            <div class="variable-field">
              <label for="var_${v}">${label}</label>
              <input type="text" id="var_${v}" name="template_data[${v}]" placeholder="${label}...">
            </div>
          `;
        }).join('');
        templateVariables.style.display = 'block';
      } else {
        templateVariables.style.display = 'none';
      }
    } catch (err) {
      console.error('Failed to load template variables:', err);
      templateVariables.style.display = 'none';
    }
  });

  // Send handler
  sendButton.addEventListener('click', async () => {
    const validRecipients = recipients.filter(isValidEmail);
    if (validRecipients.length === 0) return;

    const templateId = templateSelect.value;
    if (!templateId) return;

    // Collect template data
    const templateData = {};
    variablesGrid.querySelectorAll('input').forEach(input => {
      const name = input.name.match(/template_data\[(\w+)\]/);
      if (name) {
        templateData[name[1]] = input.value;
      }
    });

    // Show loading
    sendOverlay.classList.add('active');
    sendButton.querySelector('.btn-text').style.display = 'none';
    sendButton.querySelector('.btn-loader').style.display = 'inline-flex';
    sendButton.disabled = true;

    try {
      const createUrl = document.getElementById('sendCreateUrl').dataset.url;
      const response = await fetch(createUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          recipients: validRecipients.join(','),
          template_id: templateId,
          template_data: templateData
        })
      });

      const result = await response.json();

      // Hide loading, show result
      sendOverlay.classList.remove('active');
      sendForm.style.display = 'none';

      if (result.failed > 0) {
        resultSuccess.style.display = 'none';
        resultPartial.style.display = 'flex';
        resultMessage.innerHTML = `<strong>${result.sent}</strong> emails sent, <span class="failed">${result.failed}</span> failed`;
      } else {
        resultSuccess.style.display = 'flex';
        resultPartial.style.display = 'none';
        resultMessage.innerHTML = `<strong>${result.sent}</strong> emails sent successfully!`;
      }

      sendResult.style.display = 'flex';
    } catch (err) {
      console.error('Send failed:', err);
      sendOverlay.classList.remove('active');
      sendButton.querySelector('.btn-text').style.display = 'inline';
      sendButton.querySelector('.btn-loader').style.display = 'none';
      sendButton.disabled = false;
      alert('Failed to send emails. Please try again.');
    }
  });

  // Reset handler
  resetButton.addEventListener('click', () => {
    recipients = [];
    renderTags();
    updateCount();
    templateSelect.value = '';
    templateVariables.style.display = 'none';
    variablesGrid.innerHTML = '';
    sendResult.style.display = 'none';
    sendForm.style.display = 'block';
    sendButton.querySelector('.btn-text').style.display = 'inline';
    sendButton.querySelector('.btn-loader').style.display = 'none';
    updateSendButton();
    recipientInput.focus();
  });

  // Initialize
  updateCount();
  updateSendButton();
})();
