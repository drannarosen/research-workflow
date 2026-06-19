#!/usr/bin/env node
import plugin from '../mystmd-plugins/interactive.mjs';

const directives = new Map(plugin.directives.map((d) => [d.name, d]));
const assert = (condition, message) => {
  if (!condition) throw new Error(message);
};
const render = (name, data) => directives.get(name).run(data)[0].value;

const hostileTitle = '</script><script>throw new Error("pwned")</script>';
const plotly = render('plotly', {
  body: JSON.stringify({ data: [], layout: { title: hostileTitle } }),
  options: { height: 300 },
});
assert(plotly.includes('\\u003c/script\\u003e'), 'plotly user JSON should be escaped for script context');
assert(!plotly.includes(hostileTitle), 'plotly output must not contain raw closing script payload');

const vega = render('vega-lite', {
  body: JSON.stringify({ data: { values: [{ a: '<tag>' }] }, mark: 'point' }),
  options: {},
});
assert(vega.includes('\\u003ctag\\u003e'), 'vega user JSON should be escaped for script context');

const aladin = render('aladin', {
  options: { target: "M31');globalThis.__pwned=1;//", survey: "P/DSS2/color';oops='", fov: 1 },
});
assert(!aladin.includes("target:'"), 'aladin target must not be interpolated as a single-quoted JS literal');
assert(!aladin.includes("survey:'"), 'aladin survey must not be interpolated as a single-quoted JS literal');
assert(aladin.includes('&quot;target&quot;'), 'aladin config should be serialized as JSON in srcdoc');

const invalid = render('plotly', { body: '{not json}', options: {} });
assert(invalid.includes('Invalid plotly JSON'), 'invalid JSON should produce a visible error node');

console.log('interactive plugin checks passed');
