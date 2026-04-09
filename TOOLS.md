# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

---

## 🤖 模型 API 配置

### 小米 MiMo 系列

```yaml
provider: xiaomi-mimo
api_key: tp-cow6uyoe9ztn4c56avlhko7uxsswwfay4728egjkusqdn8xc
base_url: https://token-plan-cn.xiaomimimo.com/v1
protocol: OpenAI 兼容

模型列表:
  - MiMo-V2-Pro      # 多模态理解/视觉分析
  - MiMo-V2-Omni     # 图文混排/文档创作
  - MiMo-V2-TTS      # 中文语音合成

团队角色分配:
  - analyst: MiMo-V2-Pro    # 需求分析（多模态）
  - designer: MiMo-V2-Pro   # UI/UX 设计（视觉分析）
  - writer: MiMo-V2-Omni    # 技术文档（图文混排）
  - tts: MiMo-V2-TTS        # 语音输出（中文）
  - developer: qwen3-coder-next  # 保持原有（代码能力更强）
  - tester: qwen3-coder-next     # 保持原有（代码相关）
```

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.
