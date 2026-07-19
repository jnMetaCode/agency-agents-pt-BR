#!/usr/bin/env node
// 校验 README/package.json 的角色总数与实际角色文件一致（对齐 agency-agents-zh 的发布门禁）。
// 角色 = 带 name frontmatter 的 .md（跳过 . 开头目录 / node_modules / scripts / integrations / examples）。
// 用法: node scripts/check-counts.mjs   （不一致则以非零码退出，可用于 CI / 发布前自检）
import { readdirSync, readFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const SKIP = new Set(["node_modules", "scripts", "integrations", "examples", ".git"]);

function countAgents(dir) {
  let n = 0;
  const walk = (d) => {
    for (const e of readdirSync(d, { withFileTypes: true })) {
      if (e.name.startsWith(".") || SKIP.has(e.name)) continue;
      const f = join(d, e.name);
      if (e.isDirectory()) walk(f);
      else if (e.name.endsWith(".md")) {
        const m = readFileSync(f, "utf8").match(/^---\n([\s\S]*?)\n---/);
        if (m && /^\s*name\s*:/m.test(m[1])) n++;
      }
    }
  };
  for (const c of readdirSync(dir, { withFileTypes: true })) {
    if (c.isDirectory() && !c.name.startsWith(".") && !SKIP.has(c.name)) walk(join(dir, c.name));
  }
  return n;
}

const actual = countAgents(root);
const problems = [];
const pkg = readFileSync(join(root, "package.json"), "utf8").match(/(\d+)\s*plug-and-play/);
if (pkg && Number(pkg[1]) !== actual) problems.push(`package.json 描述写 ${pkg[1]}，实际 ${actual}`);
const readme = readFileSync(join(root, "README.md"), "utf8").match(/\*\*(\d+)\b/);
if (readme && Number(readme[1]) !== actual) problems.push(`README.md 头部写 ${readme[1]}，实际 ${actual}`);

if (problems.length) {
  console.error(`❌ 角色计数不一致（实际 ${actual} 个）：`);
  problems.forEach((p) => console.error("   - " + p));
  console.error("   请更新 README.md / package.json 后再发布。");
  process.exit(1);
}
console.log(`✅ 角色计数一致：${actual} 个`);
