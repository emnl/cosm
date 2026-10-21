ObjC.import('Foundation');
function run(argv) {
  var p = argv[0];
  var s = $.NSString.stringWithContentsOfFileEncodingError(p, $.NSUTF8StringEncoding, null);
  if (!s || s.isNil()) return '';
  var w = JSON.parse(ObjC.unwrap(s));
  var leaves = [];
  (function walk(n, inMain) {
    if (!n || typeof n !== 'object') return;
    if (n.type === 'leaf') leaves.push({ id: n.id, file: n.state && n.state.state && n.state.state.file, view: n.state && n.state.type, main: inMain });
    (n.children || []).forEach(function (c) { walk(c, inMain); });
  })(w.main, true);
  ['left', 'right'].forEach(function (k) { (function walk(n) { if (!n || typeof n !== 'object') return; if (n.type === 'leaf') leaves.push({ id: n.id, file: n.state && n.state.state && n.state.state.file, view: n.state && n.state.type, main: false }); (n.children || []).forEach(walk); })(w[k]); });
  var a = leaves.filter(function (l) { return l.id === w.active; })[0];
  if (a && a.main && a.file) return a.file;
  var recent = (w.lastOpenFiles || []);
  var mainFiles = leaves.filter(function (l) { return l.main && l.file; }).map(function (l) { return l.file; });
  for (var i = 0; i < recent.length; i++) if (mainFiles.indexOf(recent[i]) >= 0) return recent[i];
  return mainFiles[0] || '';
}
