function copyOE(btn, oeNumber) {
  navigator.clipboard.writeText(oeNumber).then(() => {
    const orig = btn.textContent;
    btn.textContent = '✓';
    btn.classList.add('copy-flash');
    setTimeout(() => {
      btn.textContent = orig;
      btn.classList.remove('copy-flash');
    }, 1200);
  }).catch(() => {
    const ta = document.createElement('textarea');
    ta.value = oeNumber;
    document.body.appendChild(ta);
    ta.select();
    document.execCommand('copy');
    document.body.removeChild(ta);
  });
}

function highlightPart(legendItem) {
  const num = parseInt(legendItem.getAttribute('data-num'));

  document.querySelectorAll('.legend-item').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.part-row').forEach(el => el.classList.remove('highlighted'));
  document.querySelectorAll('.svg-part-group').forEach(el => {
    el.style.filter = '';
    el.style.opacity = '1';
  });

  legendItem.classList.add('active');

  const row = document.querySelector(`.part-row[data-num="${num}"]`);
  if (row) {
    row.classList.add('highlighted');
    row.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }

  const svgEl = document.getElementById(`svgPart${num}`);
  if (svgEl) {
    document.querySelectorAll('.svg-part-group').forEach(el => el.style.opacity = '0.3');
    svgEl.style.opacity = '1';
    svgEl.style.filter = 'drop-shadow(0 0 12px rgba(0,170,255,0.8))';
  }
}

function highlightFromTable(row) {
  const num = parseInt(row.getAttribute('data-num'));
  const legendItem = document.querySelector(`.legend-item[data-num="${num}"]`);
  if (legendItem) highlightPart(legendItem);
}

let lastScroll = 0;
const navbar = document.querySelector('.navbar');
if (navbar) {
  window.addEventListener('scroll', () => {
    const current = window.scrollY;
    if (current > lastScroll && current > 100) {
      navbar.style.transform = 'translateY(-100%)';
    } else {
      navbar.style.transform = '';
    }
    lastScroll = current;
  }, { passive: true });
}

document.querySelectorAll('.group-card, .component-card').forEach(card => {
  card.addEventListener('mousemove', (e) => {
    const rect = card.getBoundingClientRect();
    const x = ((e.clientX - rect.left) / rect.width) * 100;
    const y = ((e.clientY - rect.top) / rect.height) * 100;
    card.style.setProperty('--mx', x + '%');
    card.style.setProperty('--my', y + '%');
  });
});

const vinForm = document.getElementById('vinForm');
const decodeBtn = document.getElementById('decodeBtn');
if (vinForm) {
  vinForm.addEventListener('submit', () => {
    if (decodeBtn) {
      decodeBtn.querySelector('.btn-text').textContent = 'Decoding…';
      decodeBtn.querySelector('.btn-arrow').textContent = '⟳';
      decodeBtn.disabled = true;
    }
  });
}
