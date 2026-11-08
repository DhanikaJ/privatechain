# Starts the private node, unlocks the signer and seals a block every 5 seconds.
# Run from the repo root:
#   powershell -ExecutionPolicy Bypass -File scripts\start.ps1
# Then attach a console from a second terminal with:  geth attach
param([string]$Datadir = "data")
$ErrorActionPreference = "Stop"

$signerFile = Join-Path $Datadir "signer.txt"
if (-not (Test-Path $signerFile)) {
    throw "No chain found in '$Datadir'. Run scripts\init.ps1 first."
}
$signer = (Get-Content $signerFile -Raw).Trim()

# --nodiscover / --maxpeers 0 keep the node isolated: nothing connects in or out.
geth --datadir $Datadir `
    --networkid 4242 `
    --nodiscover --maxpeers 0 `
    --mine --miner.etherbase $signer `
    --unlock $signer --password (Join-Path $Datadir "password.txt")
