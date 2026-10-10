# Regenerates the web PWA/favicon icons from a wedding's hero photo.
#
# Usage (from the project root):
#   powershell -ExecutionPolicy Bypass -File tool/generate_icons.ps1 -Hero "assets/weddings/ahmed-aya/hero.jpg"
#
# Optional: -OutDir "web" (default). Overwrites, in-place:
#   web/favicon.png                48x48
#   web/icons/Icon-192.png         192x192
#   web/icons/Icon-512.png         512x512
#   web/icons/Icon-maskable-192.png  192x192 (full-bleed)
#   web/icons/Icon-maskable-512.png  512x512 (full-bleed)
#   web/icons/apple-touch-icon.png   180x180
#
# A photo has no critical content, so the regular and maskable crops are the
# same full-bleed cover-crop square.

param(
    [Parameter(Mandatory = $true)]
    [string]$Hero,
    [string]$OutDir = "web"
)

Add-Type -AssemblyName System.Drawing

function New-CoverSquareIcon {
    param([System.Drawing.Image]$Source, [int]$Size, [string]$OutPath)

    $sourceW = $Source.Width
    $sourceH = $Source.Height
    $side = [Math]::Min($sourceW, $sourceH)
    $cropX = [int](($sourceW - $side) / 2)
    $cropY = [int](($sourceH - $side) / 2)

    $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
    $gfx = [System.Drawing.Graphics]::FromImage($bmp)
    $gfx.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gfx.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $gfx.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Size, $Size)
    $srcRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $side, $side)
    $gfx.DrawImage($Source, $rect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $gfx.Dispose()

    $dir = Split-Path -Parent $OutPath
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $bmp.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output "  wrote $OutPath ($Size x $Size)"
}

if (-not (Test-Path -LiteralPath $Hero)) {
    Write-Error "Hero image not found: $Hero"
    exit 1
}

$source = [System.Drawing.Image]::FromFile((Resolve-Path -LiteralPath $Hero))
try {
    New-CoverSquareIcon -Source $source -Size 48 -OutPath "$OutDir/favicon.png"
    New-CoverSquareIcon -Source $source -Size 192 -OutPath "$OutDir/icons/Icon-192.png"
    New-CoverSquareIcon -Source $source -Size 512 -OutPath "$OutDir/icons/Icon-512.png"
    New-CoverSquareIcon -Source $source -Size 192 -OutPath "$OutDir/icons/Icon-maskable-192.png"
    New-CoverSquareIcon -Source $source -Size 512 -OutPath "$OutDir/icons/Icon-maskable-512.png"
    New-CoverSquareIcon -Source $source -Size 180 -OutPath "$OutDir/icons/apple-touch-icon.png"
} finally {
    $source.Dispose()
}

Write-Output "Icons regenerated from $Hero"