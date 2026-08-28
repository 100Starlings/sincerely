(function() {
  // Line Chart interactions
  function initLineChart() {
    const chart = document.getElementById('lineChart');
    if (!chart) return;

    const lines = chart.querySelectorAll('.line-chart-line');
    const areas = chart.querySelectorAll('.line-chart-area');
    const legendItems = chart.querySelectorAll('.line-chart-legend-item');

    function highlightState(state) {
      lines.forEach(line => {
        if (line.dataset.state === state) {
          line.classList.add('highlighted');
          line.classList.remove('dimmed');
        } else {
          line.classList.add('dimmed');
          line.classList.remove('highlighted');
        }
      });
      areas.forEach(area => {
        if (area.dataset.state === state) {
          area.classList.add('highlighted');
          area.classList.remove('dimmed');
        } else {
          area.classList.add('dimmed');
          area.classList.remove('highlighted');
        }
      });
      legendItems.forEach(item => {
        if (item.dataset.state === state) {
          item.classList.add('highlighted');
          item.classList.remove('dimmed');
        } else {
          item.classList.add('dimmed');
          item.classList.remove('highlighted');
        }
      });
    }

    function resetHighlight() {
      lines.forEach(line => line.classList.remove('highlighted', 'dimmed'));
      areas.forEach(area => area.classList.remove('highlighted', 'dimmed'));
      legendItems.forEach(item => item.classList.remove('highlighted', 'dimmed'));
    }

    legendItems.forEach(item => {
      item.addEventListener('mouseenter', () => highlightState(item.dataset.state));
      item.addEventListener('mouseleave', resetHighlight);
    });

    lines.forEach(line => {
      line.addEventListener('mouseenter', () => highlightState(line.dataset.state));
      line.addEventListener('mouseleave', resetHighlight);
    });

    areas.forEach(area => {
      area.addEventListener('mouseenter', () => highlightState(area.dataset.state));
      area.addEventListener('mouseleave', resetHighlight);
    });
  }

  // Donut Chart interactions
  function initDonutChart() {
    const chart = document.getElementById('donutChart');
    if (!chart) return;

    const segments = chart.querySelectorAll('.donut-segment');
    const legendItems = chart.querySelectorAll('.donut-legend-item');

    function highlightState(state) {
      segments.forEach(seg => {
        if (seg.dataset.state === state) {
          seg.classList.add('highlighted');
          seg.classList.remove('dimmed');
        } else {
          seg.classList.add('dimmed');
          seg.classList.remove('highlighted');
        }
      });
      legendItems.forEach(item => {
        if (item.dataset.state === state) {
          item.classList.add('highlighted');
          item.classList.remove('dimmed');
        } else {
          item.classList.add('dimmed');
          item.classList.remove('highlighted');
        }
      });
    }

    function resetHighlight() {
      segments.forEach(seg => {
        seg.classList.remove('highlighted', 'dimmed');
      });
      legendItems.forEach(item => {
        item.classList.remove('highlighted', 'dimmed');
      });
    }

    legendItems.forEach(item => {
      item.addEventListener('mouseenter', () => highlightState(item.dataset.state));
      item.addEventListener('mouseleave', resetHighlight);
    });

    segments.forEach(seg => {
      seg.addEventListener('mouseenter', () => highlightState(seg.dataset.state));
      seg.addEventListener('mouseleave', resetHighlight);
    });
  }

  // Initialize all charts
  initLineChart();
  initDonutChart();
})();
