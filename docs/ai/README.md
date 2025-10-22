# AI 文档导航

## 文档功能定位

本目录包含AI助手专用文档，提供项目特定的上下文信息、约束条件和工作指导。

| 文档 | 主要功能 | 使用时机 |
|------|----------|----------|
| **[../../CLAUDE.md](../../CLAUDE.md)** | 项目核心上下文 | 每次工作开始时 |
| **[workflow.md](workflow.md)** | 工作流程与开发模式指南 | 选择工作方法、开发决策时 |
| **[constraints.md](constraints.md)** | 设计约束指南 | 代码生成和技术决策时 |
| **[troubleshooting.md](troubleshooting.md)** | 工程上下文增强包 | 遇到环境或工程问题时 |

## 标准工作流程

1. **了解项目状态** → 阅读主文档 CLAUDE.md
2. **检查经验教训** → 查阅 troubleshooting.md 核心教训
3. **选择工作方法** → 参考 workflow.md
4. **遵循技术约束** → 查阅 constraints.md
5. **应用开发模式** → 使用 workflow.md 中的开发模式

## 场景化文档组合

| 场景 | 必读文档 | 参考文档 |
|------|----------|----------|
| 新功能开发 | CLAUDE.md, constraints.md | workflow.md |
| 问题修复 | CLAUDE.md, troubleshooting.md | workflow.md |
| 代码重构 | CLAUDE.md, constraints.md | workflow.md |
| 环境配置 | troubleshooting.md | workflow.md |

## 快速问题定位

- **环境问题** → troubleshooting.md
- **技术规范** → constraints.md
- **工作流程** → workflow.md
- **项目信息** -> CLAUDE.md

---

## AI 文档设计原则

1. **面向AI，而非人类** - 所有文档专门为AI助手设计，不包含人类学习指导内容
2. **项目特有，而非通用** - 只保留AI无法从通用知识中获得的项目特定信息
3. **增强能力，而非教学** - 专注增强AI的项目上下文能力，避免通用技术教学
4. **高信息密度，而非装饰** - 去除所有表情符号、装饰性内容和冗余解释
