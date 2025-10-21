# PowerShell中文脚本标准模板
# 要求: UTF-8编码 + BOM头 + chcp 65001

chcp 65001 | Out-Null

# 脚本正文开始...
Write-Host "中文脚本模板 - 完美支持中文字符" -ForegroundColor Green
Write-Host "创建时间: $(Get-Date)" -ForegroundColor Gray

# 测试各种中文场景
Write-Host ""
Write-Host "✅ 变量名: $服务名称 = '用户服务'" -ForegroundColor Yellow
Write-Host "✅ 函数名: function Get-用户信息 {}" -ForegroundColor Cyan
Write-Host "✅ 注释: 这是中文注释" -ForegroundColor Magenta
Write-Host "✅ 字符串: '你好，世界！'" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 中文支持完美！" -ForegroundColor Green