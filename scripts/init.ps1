# Creates two throwaway test accounts, builds genesis.json from the template
# and initialises a fresh chain in ./data. Run from the repo root:
#   powershell -ExecutionPolicy Bypass -File scripts\init.ps1
param([string]$Datadir = "data")
$ErrorActionPreference = "Stop"

if (-not (Get-Command geth -ErrorAction SilentlyContinue)) {
    throw "geth was not found on PATH. Install go-ethereum first (see README)."
}
if (Test-Path (Join-Path $Datadir "geth")) {
    throw "'$Datadir' is already initialised. Delete it to start a fresh chain."
}

New-Item -ItemType Directory -Force $Datadir | Out-Null
$passwordFile = Join-Path $Datadir "password.txt"

# Random password for LOCAL TEST accounts only. It stays in ./data (git-ignored).
$chars = [char[]]"abcdefghijklmnopqrstuvwxyz0123456789"
$password = -join (1..24 | ForEach-Object { $chars | Get-Random })
Set-Content -Path $passwordFile -Value $password -NoNewline -Encoding ascii

function New-TestAccount {
    $output = (geth --datadir $Datadir account new --password $passwordFile) -join "`n"
    if ($output -match "0x([0-9a-fA-F]{40})") { return $Matches[1].ToLower() }
    throw "Could not read the new account address from geth output:`n$output"
}

$signer   = New-TestAccount   # seals blocks and is the first funded account
$account2 = New-TestAccount   # second funded account to send transactions to

$genesis = (Get-Content "genesis.template.json" -Raw).
    Replace("__SIGNER__", $signer).
    Replace("__ACCOUNT2__", $account2)
$genesisFile = Join-Path $Datadir "genesis.json"
Set-Content -Path $genesisFile -Value $genesis -Encoding ascii

Set-Content -Path (Join-Path $Datadir "signer.txt") -Value "0x$signer" -NoNewline -Encoding ascii

geth --datadir $Datadir init $genesisFile

Write-Host ""
Write-Host "Chain initialised."
Write-Host "  signer:   0x$signer"
Write-Host "  account2: 0x$account2"
Write-Host "Next: scripts\start.ps1"
