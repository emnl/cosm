// cosm helper: opens the chat at start if it was closed, keeps the right sidebar for the chat alone (pinned), shows an answer's token count on its "Worked for" line, names shell commands in plain words ("gran · Reading a table" instead of "Bash"), and shows MCP tool names in the Claudian chat as "Gmail · Search threads"
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

// A shell command's row says "Bash". Claudian keeps the command's first 60 characters in a hidden summary beside it;
// from that, say in plain words what is happening. Display only: an unknown command reads "Running a command".
const COSM = [
  [/^gran-query\b/, "gran · Reading a table"], [/^gran-exec\b/, "gran · Writing to a table"],
  [/^gran-import\b/, "gran · Loading a file into a table"], [/^gran-(describe|list)\b/, "gran · Looking at your tables"],
  [/^search-logs\b/, "Searching your logs"], [/^search(-explain)?\b/, "Searching your notes"],
  [/^update-/, "Updating cosm"], [/^fixes\b/, "Checking known fixes"], [/./, "cosm · Checking your vault"],
];
const SHELL = [
  [/^(ls|find|fd)\b/, "Looking through folders"], [/^(cat|head|tail|sed -n|less)\b/, "Reading a file"],
  [/^mv\b/, "Moving a file"], [/^mkdir\b/, "Making a folder"], [/^(cp|rsync)\b/, "Copying a file"],
  [/^(grep|rg)\b/, "Searching in files"], [/^(uv run|uvx|~\/\.local\/bin\/uv)\b/, "Running a tool (Word, Excel, PDF …)"],
  [/^curl\b/, "Fetching from the web"], [/^textutil\b/, "Converting a document"], [/^unzip\b/, "Unpacking a file"],
  [/^date\b/, "Checking the date"], [/^open\b/, "Opening a file"],
];
function shellLabel(cmd) {
  const parts = cmd.replace(/\.\.\.$/, "").split(/\s*(?:&&|\|\||;|\|)\s*/).map((x) => x.trim()).filter(Boolean);
  for (const part of parts) {
    const m = /^(?:\/bin\/)?bash\s+\.claude\/scripts\/cosm\.sh\s+(\S+)/.exec(part);
    if (m) return COSM.find(([re]) => re.test(m[1]))[1];
  }
  for (const part of parts) {
    const hit = SHELL.find(([re]) => re.test(part));
    if (hit) return hit[1];
  }
  return "Running a command";
}
function labelBash(nameEl) {
  if (nameEl.dataset.cosmBash === undefined && (nameEl.textContent || "").trim() !== "Bash") return;
  const summary = nameEl.parentElement && nameEl.parentElement.querySelector(".claudian-tool-summary");
  const cmd = summary ? (summary.textContent || "").trim() : "";
  if (!cmd) return;
  const label = shellLabel(cmd);
  if (nameEl.textContent !== label) { nameEl.dataset.cosmBash = ""; nameEl.textContent = label; }
}

function fixIn(root) {
  if (!root || !root.querySelectorAll) return;
  const els = root.matches && root.matches(".claudian-tool-name") ? [root] : root.querySelectorAll(".claudian-tool-name");
  els.forEach((el) => {
    const p = pretty(el.textContent || "");
    if (p) el.textContent = p;
    else labelBash(el);
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
        const summary = target && target.closest && target.closest(".claudian-tool-summary");
        if (summary && summary.parentElement) fixIn(summary.parentElement);
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
