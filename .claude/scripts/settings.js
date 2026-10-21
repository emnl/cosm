// Sets cosm's own settings inside files the user also changes, leaving every other setting alone.
// Run by cosm.sh update-settings: osascript -l JavaScript .claude/scripts/settings.js <vault root>
// Reads .claude/scripts/settings.json: { "<file>": { "set": {key: value}, "add": {key: [items]},
//   "drop": {key: [items]}, "remove": [key] } }. Keys may be dotted ("permissions.allow").
// Prints one line per file it changed (SET …), or SKIP / FAIL lines; nothing when all is in place.
ObjC.import('Foundation');

function read(p) {
  const s = $.NSString.stringWithContentsOfFileEncodingError(p, $.NSUTF8StringEncoding, null);
  return s.isNil() ? null : ObjC.unwrap(s);
}

function write(p, text) {
  const dir = $(p).stringByDeletingLastPathComponent;
  $.NSFileManager.defaultManager.createDirectoryAtPathWithIntermediateDirectoriesAttributesError(dir, true, $(), null);
  return $(text).writeToFileAtomicallyEncodingError(p, true, $.NSUTF8StringEncoding, null);
}

function walk(obj, path, create) {
  const parts = path.split('.');
  let o = obj;
  for (let i = 0; i < parts.length - 1; i++) {
    if (typeof o[parts[i]] !== 'object' || o[parts[i]] === null || Array.isArray(o[parts[i]])) {
      if (!create) return [null, null];
      o[parts[i]] = {};
    }
    o = o[parts[i]];
  }
  return [o, parts[parts.length - 1]];
}

const same = (a, b) => JSON.stringify(a) === JSON.stringify(b);

function run(argv) {
  const root = argv[0];
  const specText = read(root + '/.claude/scripts/settings.json');
  if (specText === null) return 'FAIL no .claude/scripts/settings.json';
  let spec;
  try { spec = JSON.parse(specText); } catch (e) { return 'FAIL .claude/scripts/settings.json is not valid JSON'; }
  const out = [];
  for (const f of Object.keys(spec)) {
    if (!/^\.(claudian|obsidian|claude)\//.test(f) || f.indexOf('..') >= 0) { out.push('SKIP bad path: ' + f); continue; }
    const p = root + '/' + f;
    const text = read(p);
    let obj = {};
    if (text !== null && text.trim() !== '') {
      try { obj = JSON.parse(text); } catch (e) { out.push('FAIL not JSON: ' + f); continue; }
    }
    const s = spec[f];
    const changed = [];
    for (const k of Object.keys(s.set || {})) {
      const [o, last] = walk(obj, k, true);
      if (!same(o[last], s.set[k])) { o[last] = s.set[k]; changed.push(k); }
    }
    for (const k of Object.keys(s.add || {})) {
      const [o, last] = walk(obj, k, true);
      if (!Array.isArray(o[last])) o[last] = [];
      let n = 0;
      for (const item of s.add[k]) if (!o[last].some(x => same(x, item))) { o[last].push(item); n++; }
      if (n) changed.push(k + ' +' + n);
    }
    for (const k of Object.keys(s.drop || {})) {
      const [o, last] = walk(obj, k, false);
      if (!o || !Array.isArray(o[last])) continue;
      const before = o[last].length;
      o[last] = o[last].filter(x => !s.drop[k].some(item => same(x, item)));
      if (o[last].length < before) changed.push(k + ' -' + (before - o[last].length));
    }
    for (const k of (s.remove || [])) {
      const [o, last] = walk(obj, k, false);
      if (o && Object.prototype.hasOwnProperty.call(o, last)) { delete o[last]; changed.push('-' + k); }
    }
    if (!changed.length) continue;
    if (write(p, JSON.stringify(obj, null, 2) + '\n')) out.push('SET ' + f + ': ' + changed.join(', '));
    else out.push('FAIL could not write ' + f);
  }
  return out.join('\n');
}
