# PowerShell脚本编码规范

## 🎯 核心原则

**编码优先级**: 英文脚本 > 中文脚本（避免编码问题）

## 📝 PowerShell脚本标准模板

### 1. 英文脚本模板（推荐）
```powershell
# Script Name: health-check-en.ps1
# Description: English PowerShell script template
# Author: Test Persona
# Version: 1.0

param(
    [string]$service = "",
    [switch]$help = $false
)

# Main logic
Write-Host "=== Health Check ===" -ForegroundColor Green
```

### 2. 中文脚本模板（特殊情况）
**必须条件**:
- ✅ UTF-8编码 + BOM头
- ✅ 脚本开头: `chcp 65001 | Out-Null`

```powershell
# 中文PowerShell脚本模板
# 要求: UTF-8编码 + BOM头 + chcp 65001

chcp 65001 | Out-Null

param(
    [string]$service = "",
    [switch]$help = $false
)

# 主要逻辑
Write-Host "=== 健康检查 ===" -ForegroundColor Green
```

## 🔧 BOM头添加方法

### 方法1: 使用printf命令
```bash
printf '\xEF\xBB\xBF' > temp_bom.txt && cat script.ps1 >> temp_bom.txt && mv temp_bom.txt script.ps1
```

### 方法2: 使用PowerShell
```powershell
$content = Get-Content 'script.ps1' -Raw
$utf8WithBom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText('script.ps1', $content, $utf8WithBom)
```

## ⚠️ 重要注意事项

1. **文件保存**: 确保编辑器支持UTF-8 BOM
2. **编码验证**: 使用支持中文的终端测试脚本
3. **版本兼容**: PowerShell 5.1需要特殊处理，PowerShell 7+原生支持UTF-8
4. **团队协作**: 统一编码标准，避免不同环境问题

## 🔗 认证信息参考

### 服务连接凭据
详细认证信息请参考：[`test-mode.md`](../test-mode.md#服务认证信息)

**快速连接命令**：
```powershell
# MySQL (root用户)
docker exec mysql mysql -u root -proot123456 -e "SELECT 'MySQL OK' as status;"

# Redis
docker exec redis redis-cli -a redis123456 ping

# Nacos Web登录
# 用户名: nacos, 密码: nacos
# 地址: http://localhost:18848/nacos
```

## 📚 参考资料

- [CLAUDE.md重要运维经验教训](../../CLAUDE.md)
- [故障排查手册](../../deploy/docs/TROUBLESHOOTING.md)
- [测试模式配置](../test-mode.md)
- [环境变量配置](../../deploy/docker-compose/.env)

---

**版本**: v1.0
**最后更新**: 2025-10-21
**维护者**: Test Persona