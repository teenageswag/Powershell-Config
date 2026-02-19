Write-Host "=== Завершение установки профиля ===" -ForegroundColor Cyan
Write-Host ""

$tempProfile = "$PROFILE.new"

if (Test-Path $tempProfile) {
    try {
        Move-Item $tempProfile $PROFILE -Force -ErrorAction Stop
        Write-Host "✓ Профиль успешно установлен!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Перезапустите Windows Terminal для применения изменений." -ForegroundColor Yellow
    } catch {
        Write-Host "✗ Ошибка: Не удалось переместить профиль" -ForegroundColor Red
        Write-Host "  Убедитесь, что все окна PowerShell закрыты" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Попробуйте выполнить вручную:" -ForegroundColor Yellow
        Write-Host "  Move-Item '$tempProfile' '$PROFILE' -Force" -ForegroundColor Gray
    }
} else {
    Write-Host "✓ Временный профиль не найден" -ForegroundColor Green
    Write-Host "  Профиль уже установлен или не требует обновления" -ForegroundColor Gray
}

Write-Host ""
