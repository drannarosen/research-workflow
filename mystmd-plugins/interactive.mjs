// interactive.mjs — mystmd plugin: interactive-figure directives for static MyST sites.
//
// Load it from a site's myst.yml:
//   project:
//     plugins:
//       - path/to/interactive.mjs        # local copy, or reference this file
//
// Provides: {plotly}, {vega-lite}, {aladin}
//
// WHY IFRAMES: MyST sanitizes inline <script> in the page itself, so third-party JS can't run from a
// raw `html` node directly. Each directive therefore emits an <iframe srcdoc="..."> — the widget runs
// in its own document/realm (also avoids SSR/hydration clashes). These render in the static HTML build
// (no kernel needed); they do NOT render in PDF/Word exports (provide a :poster:/static fallback there).
//
// STATUS: starter (0.1.0) — VALIDATE against your installed mystmd version per the de-risk milestone in
// the `interactive-figures` skill (prove mermaid + a notebook Plotly output + a bare iframe first). If
// your build strips <iframe srcdoc>, switch to the standalone-page fallback documented in that skill.

const esc = (s) =>
  String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;');

const iframeNode = (innerHtml, height = 420) => [{
  type: 'html',
  value: `<iframe style="width:100%;height:${Number(height)}px;border:0" loading="lazy" srcdoc="${esc(innerHtml)}"></iframe>`,
}];

const plotly = {
  name: 'plotly',
  doc: 'Interactive Plotly figure from a JSON spec (the output of fig.to_json()).',
  options: { height: { type: Number, doc: 'iframe height in px (default 420)' } },
  body: { type: String, doc: 'Plotly JSON: {"data":[...],"layout":{...}}' },
  run(data) {
    const spec = (data.body || '{}').trim();
    const html = `<!doctype html><meta charset="utf-8">
<script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
<div id="fig"></div>
<script>const s=${spec};Plotly.newPlot('fig',s.data||[],s.layout||{},{responsive:true});</script>`;
    return iframeNode(html, data.options?.height);
  },
};

const vegaLite = {
  name: 'vega-lite',
  doc: 'Interactive Vega-Lite chart from a JSON spec.',
  options: { height: { type: Number } },
  body: { type: String, doc: 'Vega-Lite JSON spec' },
  run(data) {
    const spec = (data.body || '{}').trim();
    const html = `<!doctype html><meta charset="utf-8">
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
<div id="vis"></div>
<script>vegaEmbed('#vis',${spec},{actions:false});</script>`;
    return iframeNode(html, data.options?.height);
  },
};

const aladin = {
  name: 'aladin',
  doc: 'Interactive Aladin Lite sky atlas.',
  options: {
    target: { type: String, doc: 'Position/name, e.g. "M51" or "10.68 41.27"' },
    fov: { type: Number, doc: 'Field of view in degrees (default 1)' },
    survey: { type: String, doc: 'HiPS survey id (default P/DSS2/color)' },
    height: { type: Number },
  },
  run(data) {
    const o = data.options || {};
    const html = `<!doctype html><meta charset="utf-8">
<link rel="stylesheet" href="https://aladin.cds.unistra.fr/AladinLite/api/v3/latest/aladin.min.css">
<script src="https://aladin.cds.unistra.fr/AladinLite/api/v3/latest/aladin.js"></script>
<div id="aladin" style="width:100%;height:100vh"></div>
<script>A.init.then(()=>A.aladin('#aladin',{target:'${esc(o.target || 'M31')}',fov:${Number(o.fov ?? 1)},survey:'${esc(o.survey || 'P/DSS2/color')}'}));</script>`;
    return iframeNode(html, o.height ?? 480);
  },
};

export default {
  name: 'Interactive figures',
  directives: [plotly, vegaLite, aladin],
};
