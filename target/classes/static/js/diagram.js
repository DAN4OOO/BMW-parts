// BMW Parts Catalog — diagram.js
// Renders numbered exploded-view SVG diagram from server-side parts data

(function () {
  const svgGroup = document.getElementById('svgParts');
  const tooltip  = document.getElementById('diagramTooltip');
  const ttNum    = document.getElementById('ttNum');
  const ttName   = document.getElementById('ttName');
  const ttOe     = document.getElementById('ttOe');
  const wrapper  = document.getElementById('diagramWrapper');

  if (!svgGroup || !Array.isArray(PARTS_DATA) || PARTS_DATA.length === 0) return;

  // ── Layout configuration ──────────────────────────────────────
  // Arrange parts in a spiral / grid across the SVG canvas
  const CANVAS_W = 800;
  const CANVAS_H = 500;
  const MARGIN   = 60;

  // Color pool for part shapes
  const COLORS = [
    '#1c4a8c', '#2a5f9e', '#193f78', '#0e3168', '#255a9e',
    '#1a4a7a', '#103258', '#1e5490', '#0b2d56', '#173f72',
    '#204e8c', '#0d2f60', '#1b4980', '#265c98', '#112e5a',
  ];

  // Shape generators (returns SVG element string)
  const SHAPES = [
    // Disc / plate
    (x, y, w, h, color) =>
      `<ellipse cx="${x}" cy="${y}" rx="${w/2}" ry="${h/3}" fill="${color}" stroke="#4db8ff" stroke-width="0.8"/>`,
    // Rectangle / bracket
    (x, y, w, h, color) =>
      `<rect x="${x-w/2}" y="${y-h/2}" width="${w}" height="${h}" rx="4" fill="${color}" stroke="#4db8ff" stroke-width="0.8"/>`,
    // Hexagon bolt
    (x, y, w, h, color) => hexPath(x, y, Math.min(w,h)/2, color),
    // Cylinder
    (x, y, w, h, color) =>
      `<rect x="${x-w/2}" y="${y-h/2}" width="${w}" height="${h}" rx="${w/4}" fill="${color}" stroke="#4db8ff" stroke-width="0.8"/>
       <ellipse cx="${x}" cy="${y-h/2}" rx="${w/2}" ry="${w/5}" fill="${lighten(color)}" stroke="#4db8ff" stroke-width="0.8"/>`,
    // Diamond
    (x, y, w, h, color) =>
      `<polygon points="${x},${y-h/2} ${x+w/2},${y} ${x},${y+h/2} ${x-w/2},${y}" fill="${color}" stroke="#4db8ff" stroke-width="0.8"/>`,
  ];

  function hexPath(cx, cy, r, color) {
    const pts = [];
    for (let i = 0; i < 6; i++) {
      const angle = (Math.PI / 3) * i - Math.PI / 6;
      pts.push(`${cx + r * Math.cos(angle)},${cy + r * Math.sin(angle)}`);
    }
    return `<polygon points="${pts.join(' ')}" fill="${color}" stroke="#4db8ff" stroke-width="0.8"/>`;
  }

  function lighten(hex) {
    // Simple: increase brightness by mixing with white
    return hex; // keep same for now
  }

  // ── Compute layout positions ──────────────────────────────────
  function computePositions(count) {
    const positions = [];
    const usableW = CANVAS_W - MARGIN * 2;
    const usableH = CANVAS_H - MARGIN * 2 - 60; // 60px for title
    const cols = Math.ceil(Math.sqrt(count * (usableW / usableH)));
    const rows = Math.ceil(count / cols);
    const cellW = usableW / cols;
    const cellH = usableH / rows;

    for (let i = 0; i < count; i++) {
      const col = i % cols;
      const row = Math.floor(i / cols);
      positions.push({
        x: MARGIN + cellW * col + cellW / 2,
        y: MARGIN + 60 + cellH * row + cellH / 2,
        w: Math.min(cellW * 0.65, 90),
        h: Math.min(cellH * 0.55, 60),
      });
    }
    return positions;
  }

  // ── Build connector lines between nearby parts ────────────────
  function buildConnectors(positions) {
    let lines = '';
    for (let i = 0; i < positions.length - 1; i++) {
      const a = positions[i];
      const b = positions[i + 1];
      // midpoint curve
      const mx = (a.x + b.x) / 2;
      const my = (a.y + b.y) / 2 - 20;
      lines += `<path d="M${a.x},${a.y} Q${mx},${my} ${b.x},${b.y}"
        fill="none" stroke="#1e3a5f" stroke-width="1" stroke-dasharray="5,4" opacity="0.7"/>`;
    }
    return lines;
  }

  // ── Render all parts ──────────────────────────────────────────
  const parts = PARTS_DATA;
  const positions = computePositions(parts.length);

  let connectorsSvg = buildConnectors(positions);
  let partsSvg = '';

  parts.forEach((part, i) => {
    const pos   = positions[i];
    const color = COLORS[i % COLORS.length];
    const shape = SHAPES[i % SHAPES.length];
    const num   = part.diagramNumber;

    // Shape
    const shapeSvg = shape(pos.x, pos.y, pos.w, pos.h, color);

    // Number badge
    const badgeSvg = `
      <circle cx="${pos.x + pos.w/2 - 4}" cy="${pos.y - pos.h/2 + 4}" r="10" fill="#0070c1" stroke="#4db8ff" stroke-width="1.2"/>
      <text x="${pos.x + pos.w/2 - 4}" y="${pos.y - pos.h/2 + 8}" text-anchor="middle"
            fill="#fff" font-family="Rajdhani,sans-serif" font-size="9" font-weight="700">${num}</text>
    `;

    // Short name label
    const shortName = part.name.length > 16 ? part.name.substring(0, 14) + '…' : part.name;
    const labelSvg = `
      <text x="${pos.x}" y="${pos.y + pos.h/2 + 14}" text-anchor="middle"
            fill="#7a9bb8" font-family="Inter,sans-serif" font-size="8">${shortName}</text>
    `;

    partsSvg += `
      <g class="svg-part-group" id="svgPart${num}"
         data-num="${num}"
         data-name="${escapeAttr(part.name)}"
         data-oe="${escapeAttr(part.oeNumber)}"
         style="cursor:pointer; transition: all 0.2s;">
        ${shapeSvg}
        ${badgeSvg}
        ${labelSvg}
      </g>
    `;
  });

  svgGroup.innerHTML = connectorsSvg + partsSvg;

  // ── Interactivity: hover tooltip ──────────────────────────────
  document.querySelectorAll('.svg-part-group').forEach(el => {
    el.addEventListener('mouseenter', (e) => {
      const num  = el.getAttribute('data-num');
      const name = el.getAttribute('data-name');
      const oe   = el.getAttribute('data-oe');
      ttNum.textContent  = '#' + num;
      ttName.textContent = name;
      ttOe.textContent   = 'OE: ' + oe;
      tooltip.style.display = 'block';
    });

    el.addEventListener('mousemove', (e) => {
      const rect = wrapper.getBoundingClientRect();
      let tx = e.clientX - rect.left + 16;
      let ty = e.clientY - rect.top + 16;
      // Keep in bounds
      if (tx + 200 > rect.width)  tx = e.clientX - rect.left - 216;
      if (ty + 80  > rect.height) ty = e.clientY - rect.top  - 96;
      tooltip.style.left = tx + 'px';
      tooltip.style.top  = ty + 'px';
    });

    el.addEventListener('mouseleave', () => {
      tooltip.style.display = 'none';
    });

    el.addEventListener('click', () => {
      const num = parseInt(el.getAttribute('data-num'));
      const legendItem = document.querySelector(`.legend-item[data-num="${num}"]`);
      if (legendItem) highlightPart(legendItem);
    });
  });

  function escapeAttr(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }

})();
