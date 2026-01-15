$ErrorActionPreference = "Stop"

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RootDir

function Test-ChecksumFile {
  param(
    [Parameter(Mandatory = $true)][string]$ChecksumFile,
    [Parameter(Mandatory = $true)][string]$BaseDir,
    [Parameter(Mandatory = $true)][string]$Label
  )

  if (-not (Test-Path -LiteralPath $ChecksumFile -PathType Leaf)) {
    throw "Missing checksum file: $ChecksumFile"
  }
  if (-not (Test-Path -LiteralPath $BaseDir -PathType Container)) {
    throw "Missing base directory: $BaseDir"
  }

  Write-Host "== $Label ==" -ForegroundColor Cyan

  $failed = $false
  $lines = Get-Content -LiteralPath $ChecksumFile

  foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ($trimmed.Length -eq 0) { continue }
    if ($trimmed.StartsWith("#")) { continue }

    if ($trimmed -match "^([0-9a-fA-F]{64})\s+(.+)$") {
      $expected = $matches[1].ToLowerInvariant()
      $relativePath = $matches[2].Trim()
      $relativePath = $relativePath -replace '^[.][\\/]', ''
      $relativePath = $relativePath -replace '/', '\\'

      $fullPath = Join-Path $BaseDir $relativePath
      if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        Write-Host "MISSING: $relativePath" -ForegroundColor Red
        $failed = $true
        continue
      }

      $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $fullPath).Hash.ToLowerInvariant()
      if ($actual -ne $expected) {
        Write-Host "FAIL: $relativePath" -ForegroundColor Red
        Write-Host "  expected: $expected"
        Write-Host "  actual:   $actual"
        $failed = $true
      } else {
        Write-Host "OK:   $relativePath" -ForegroundColor Green
      }
    } else {
      Write-Host "SKIP (unparsed line): $trimmed" -ForegroundColor Yellow
    }
  }

  Write-Host ""

  if ($failed) {
    throw "Integrity check failed for: $Label"
  }
}

if (-not (Test-Path -LiteralPath "CHECKSUMS.sha256" -PathType Leaf)) {
  throw "CHECKSUMS.sha256 not found in: $RootDir"
}

Test-ChecksumFile -ChecksumFile "CHECKSUMS.sha256" -BaseDir $RootDir -Label "Verifying scripts/docs (CHECKSUMS.sha256)"
Test-ChecksumFile -ChecksumFile "checksums\\BUNDLED_FILES_SHA256.txt" -BaseDir (Join-Path $RootDir "bin") -Label "Verifying bundled grpcurl (BUNDLED_FILES_SHA256.txt)"

Write-Host "OK: Integrity checks passed." -ForegroundColor Green
