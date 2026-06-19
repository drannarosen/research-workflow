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
// STATUS: starter (0.1.1) — VALIDATE against your installed mystmd version per the de-risk milestone in
// the `interactive-figures` skill (prove mermaid + a notebook Plotly output + a bare iframe first). If
// your build strips <iframe srcdoc>, switch to the standalone-page fallback documented in that skill.

const escapeAttr = (s) => String(s).replace(/&/g, '&amp;').replace(/"/g, '&quot;');
const escapeText = (s) => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const jsonForScript = (value) => JSON.stringify(value)
  .replace(/</g, '\\u003c')
  .replace(/>/g, '\\u003e')
  .replace(/&/g, '\\u0026')
  .replace(/\u2028/g, '\\u2028')
  .replace(/\u2029/g, '\\u2029');

const iframeNode = (innerHtml, height = 420) => [{
  type: 'html',
  value: `<iframe sandbox="allow-scripts allow-popups" referrerpolicy="no-referrer" style="width:100%;height:${Number(height) || 420}px;border:0" loading="lazy" srcdoc="${escapeAttr(innerHtml)}"></iframe>`,
}];

const errorNode = (name, err, height = 180) => iframeNode(
  `<!doctype html><meta charset="utf-8"><pre style="white-space:pre-wrap;color:#8b0000;font:14px/1.4 ui-monospace,monospace">Invalid ${escapeText(name)} JSON: ${escapeText(err.message)}</pre>`,
  height,
);

const parseJsonBody = (body, name) => {
  try {
    return { ok: true, value: JSON.parse((body || '{}').trim() || '{}') };
  } catch (err) {
    return { ok: false, err: err instanceof Error ? err : new Error(String(err)), name };
  }
};

const plotly = {
  name: 'plotly',
  doc: 'Interactive Plotly figure from a JSON spec (the output of fig.to_json()).',
  options: { height: { type: Number, doc: 'iframe height in px (default 420)' } },
  body: { type: String, doc: 'Plotly JSON: {"data":[...],"layout":{...}}' },
  run(data) {
    const parsed = parseJsonBody(data.body, 'plotly');
    if (!parsed.ok) return errorNode(parsed.name, parsed.err, data.options?.height);
    const html = `<!doctype html><meta charset="utf-8">
<script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
<div id="fig"></div>
<script>const s=${jsonForScript(parsed.value)};Plotly.newPlot('fig',s.data||[],s.layout||{},{responsive:true});</script>`;
    return iframeNode(html, data.options?.height);
  },
};

const vegaLite = {
  name: 'vega-lite',
  doc: 'Interactive Vega-Lite chart from a JSON spec.',
  options: { height: { type: Number } },
  body: { type: String, doc: 'Vega-Lite JSON spec' },
  run(data) {
    const parsed = parseJsonBody(data.body, 'vega-lite');
    if (!parsed.ok) return errorNode(parsed.name, parsed.err, data.options?.height);
    const html = `<!doctype html><meta charset="utf-8">
<script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-lite@5"></script>
<script src="https://cdn.jsdelivr.net/npm/vega-embed@6"></script>
<div id="vis"></div>
<script>const spec=${jsonForScript(parsed.value)};vegaEmbed('#vis',spec,{actions:false});</script>`;
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
    const cfg = {
      target: String(o.target || 'M31'),
      fov: Number(o.fov ?? 1),
      survey: String(o.survey || 'P/DSS2/color'),
    };
    const html = `<!doctype html><meta charset="utf-8">
<link rel="stylesheet" href="https://aladin.cds.unistra.fr/AladinLite/api/v3/latest/aladin.min.css">
<script src="https://aladin.cds.unistra.fr/AladinLite/api/v3/latest/aladin.js"></script>
<div id="aladin" style="width:100%;height:100vh"></div>
<script>const cfg=${jsonForScript(cfg)};A.init.then(()=>A.aladin('#aladin',cfg));</script>`;
    return iframeNode(html, o.height ?? 480);
  },
};

export default {
  name: 'Interactive figures',
  directives: [plotly, vegaLite, aladin],
};
