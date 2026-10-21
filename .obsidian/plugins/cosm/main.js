// cosm helper: opens the chat at start if it was closed, keeps the right sidebar for the chat alone (pinned), shows an answer's token count on its "Worked for" line, and shows MCP tool names in the Claudian chat as "Gmail · Search threads"
// instead of "mcp__claude_ai_Gmail__search_threads". It only rewrites text that still
// starts with "mcp__", so it does nothing once Claudian shows friendly names itself.
const { Plugin } = require("obsidian");

function pretty(text) {
  const m = /^mcp__(.+?)__(.+)$/.exec(text.trim());
  if (!m) return null;
  const server = m[1].replace(/^claude_ai_/, "").replace(/_/g, " ");
  const tool = m[2].replace(/[_-]+/g, " ").trim();
  return server + " · " + tool.charAt(0).toUpperCase() + tool.slice(1);
}

function fixIn(root) {
  if (!root || !root.querySelectorAll) return;
  const els = root.matches && root.matches(".claudian-tool-name") ? [root] : root.querySelectorAll(".claudian-tool-name");
  els.forEach((el) => {
    const p = pretty(el.textContent || "");
    if (p) el.textContent = p;
  });
}


// Claudian keeps an answer's token count in the speed label's tooltip ("1,234 tokens · 12.3s"). Show it on the message's
// work line, and say the time the short way: "Worked 4s · 325 tokens", "Worked 1m 12s · 3.4k tokens".
// The speed label itself is hidden in cosm.css.
function shortTime(mm, ss) {
  const s = Number(mm) * 60 + Number(ss);
  return s < 60 ? s + "s" : Math.floor(s / 60) + "m " + (s % 60) + "s";
}
function shortTokens(text) {
  const n = Number(text.replace(/[^0-9]/g, ""));
  if (!n) return null;
  return (n < 1000 ? String(n) : (n / 1000).toFixed(n < 10000 ? 1 : 0).replace(/\.0$/, "") + "k") + " tokens";
}
function addTokens(root) {
  if (!root || !root.querySelectorAll) return;
  root.querySelectorAll(".claudian-response-throughput").forEach((speed) => {
    const msg = speed.closest(".claudian-message");
    const header = msg && msg.querySelector(".claudian-work-header");
    if (!header || header.querySelector(".cosm-work-tokens")) return;
    const walker = document.createTreeWalker(header, NodeFilter.SHOW_TEXT);
    for (let node = walker.nextNode(); node; node = walker.nextNode()) {
      const m = /^(.*?)(\d+):(\d\d)\s*$/.exec(node.textContent);
      if (m) {
        const lead = /^\s*Worked\s+for\s*$/.test(m[1]) ? "Worked " : m[1];
        node.textContent = lead + shortTime(m[2], m[3]);
        break;
      }
    }
    const tokens = shortTokens((speed.getAttribute("aria-label") || "").split(" · ")[0]);
    if (!tokens) return;
    const span = document.createElement("span");
    span.className = "cosm-work-tokens";
    span.textContent = "· " + tokens;
    header.appendChild(span);
  });
}

module.exports = class CosmPlugin extends Plugin {
  onload() {
    this.observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        const target = m.target.nodeType === 1 ? m.target : m.target.parentElement;
        if (target && target.closest && target.closest(".claudian-tool-name")) fixIn(target.closest(".claudian-tool-name"));
        m.addedNodes.forEach((n) => fixIn(n.nodeType === 1 ? n : n.parentElement));
      }
      if (!this.tokenTimer) this.tokenTimer = setTimeout(() => { this.tokenTimer = null; addTokens(document.body); }, 300);
    });
    this.app.workspace.onLayoutReady(() => {
      // Make sure the chat is open: cosm hides the ribbon, so a closed chat has no button to bring it back.
      if (this.app.workspace.getLeavesOfType("claudian-view").length === 0) {
        this.app.commands.executeCommandById("realclaudian:open-view");
      }
      // The right sidebar is the chat's alone, pinned so a click elsewhere can't replace it.
      setTimeout(() => this.tidySidebar(), 500);
      fixIn(document.body);
      addTokens(document.body);
      this.observer.observe(document.body, { childList: true, subtree: true, characterData: true });
    });
  }
  tidySidebar() {
    const ws = this.app.workspace;
    const right = ws.rightSplit;
    const leaves = [];
    ws.iterateAllLeaves((leaf) => { if (leaf.getRoot() === right) leaves.push(leaf); });
    leaves.forEach((leaf) => {
      if (leaf.view.getViewType() === "claudian-view") { if (!leaf.getViewState().pinned) leaf.setPinned(true); }
      else leaf.detach();
    });
  }
  onunload() {
    if (this.observer) this.observer.disconnect();
  }
};
