# quiz.html 을 고친 뒤 이 파일을 실행하면 Vercel에 다시 올라갑니다.
# 파워셸에서:  .\배포.ps1
#
# 배포 폴더(number-grid-quiz)에는 index.html 하나만 둡니다.
# api.md 같은 키 파일은 이 폴더에 들어가지 않으므로 올라갈 수 없습니다.

$root = $PSScriptRoot
$out  = Join-Path $root "number-grid-quiz"

Copy-Item (Join-Path $root "quiz.html") (Join-Path $out "index.html") -Force
Write-Host "quiz.html -> number-grid-quiz\index.html 복사 완료"

# 올리기 직전 안전 점검: 배포 폴더에 키가 섞여 있으면 중단한다
$leak = Get-ChildItem $out -File -Recurse | Select-String -Pattern 'sk-', 'OPENAI_API_KEY' -SimpleMatch -ErrorAction SilentlyContinue
if ($leak) {
    Write-Host "중단: 배포 폴더에서 키로 보이는 문자열이 발견됐습니다." -ForegroundColor Red
    $leak | ForEach-Object { Write-Host ("  " + $_.Path + ":" + $_.LineNumber) }
    exit 1
}
Write-Host "안전 점검 통과: 배포 폴더에 키 없음"

Set-Location $out
npx --yes vercel@latest deploy --prod --yes
