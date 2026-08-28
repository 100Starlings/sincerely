const TIME_LABELS = { '1h': '1h', '24h': '24h', '7d': '7d', '30d': '30d', '3m': '3m', 'all': 'All' };
const FILTERED_PAGES = ['dashboard', 'notifications', 'delivery_events', 'engagement_events'];
const CURRENT_PAGE = document.body.dataset.controller;

function toggleNav() {
  const navLinks = document.getElementById('navLinks');
  if (navLinks) navLinks.classList.toggle('open');
}

function toggleTheme() {
  const html = document.documentElement;
  const currentTheme = html.getAttribute('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  html.setAttribute('data-theme', newTheme);
  localStorage.setItem('sincerely-theme', newTheme);
}

function toggleTimeDropdown() {
  const dropdown = document.getElementById('timeDropdown');
  if (dropdown) dropdown.classList.toggle('open');
}

function setTimePeriod(period) {
  localStorage.setItem('sincerely-period', period);
  const label = document.getElementById('timeLabel');
  if (label) label.textContent = TIME_LABELS[period];
  const dropdown = document.getElementById('timeDropdown');
  if (dropdown) dropdown.classList.remove('open');
  updateActiveItem(period);

  const url = new URL(window.location);
  url.searchParams.set('period', period);
  window.location = url;
}

function updateActiveItem(period) {
  document.querySelectorAll('.time-dropdown-item').forEach(item => {
    item.classList.toggle('active', item.dataset.period === period);
  });
}

function getSavedPeriod() {
  return localStorage.getItem('sincerely-period') || '24h';
}

document.addEventListener('click', function(e) {
  const dropdown = document.getElementById('timeDropdown');
  if (dropdown && !dropdown.contains(e.target)) {
    dropdown.classList.remove('open');
  }

  const navLinks = document.getElementById('navLinks');
  const navToggle = document.querySelector('.nav-toggle');
  if (navLinks && !navLinks.contains(e.target) && !navToggle.contains(e.target)) {
    navLinks.classList.remove('open');
  }
});

document.querySelectorAll('.time-dropdown-item').forEach(item => {
  item.addEventListener('click', () => setTimePeriod(item.dataset.period));
});

document.querySelectorAll('.nav-links a').forEach(link => {
  link.addEventListener('click', function(e) {
    const navLinks = document.getElementById('navLinks');
    if (navLinks) navLinks.classList.remove('open');

    const href = this.getAttribute('href');
    const isFilteredPage = FILTERED_PAGES.some(page =>
      href.includes('/' + page) || href.endsWith('/sincerely') || href.endsWith('/sincerely/')
    );

    if (isFilteredPage) {
      e.preventDefault();
      const url = new URL(href, window.location.origin);
      url.searchParams.set('period', getSavedPeriod());
      window.location = url;
    }
  });
});

(function() {
  const savedTheme = localStorage.getItem('sincerely-theme');
  if (savedTheme) {
    document.documentElement.setAttribute('data-theme', savedTheme);
  } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    document.documentElement.setAttribute('data-theme', 'dark');
  }

  const urlParams = new URLSearchParams(window.location.search);
  const urlPeriod = urlParams.get('period');
  const savedPeriod = getSavedPeriod();
  const period = urlPeriod || savedPeriod;

  const label = document.getElementById('timeLabel');
  if (label) label.textContent = TIME_LABELS[period] || '24h';
  updateActiveItem(period);

  if (!urlPeriod && FILTERED_PAGES.includes(CURRENT_PAGE)) {
    const url = new URL(window.location);
    url.searchParams.set('period', savedPeriod);
    window.location.replace(url);
  }
})();
