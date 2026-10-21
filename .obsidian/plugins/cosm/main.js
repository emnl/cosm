// cosm helper: opens the chat at start if it was closed, and shows MCP tool names in the Claudian chat as "Gmail · Search threads"
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

module.exports = class CosmPlugin extends Plugin {
  onload() {
    this.observer = new MutationObserver((mutations) => {
      for (const m of mutations) {
        const target = m.target.nodeType === 1 ? m.target : m.target.parentElement;
        if (target && target.closest && target.closest(".claudian-tool-name")) fixIn(target.closest(".claudian-tool-name"));
        m.addedNodes.forEach((n) => fixIn(n.nodeType === 1 ? n : n.parentElement));
      }
    });
    this.app.workspace.onLayoutReady(() => {
      // Make sure the chat is open: cosm hides the ribbon, so a closed chat has no button to bring it back.
      if (this.app.workspace.getLeavesOfType("claudian-view").length === 0) {
        this.app.commands.executeCommandById("realclaudian:open-view");
      }
      fixIn(document.body);
      this.observer.observe(document.body, { childList: true, subtree: true, characterData: true });
    });
  }
  onunload() {
    if (this.observer) this.observer.disconnect();
  }
};
