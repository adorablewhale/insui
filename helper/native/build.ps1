# Build the native tray EXE using Windows' .NET Framework compiler. No downloads.
[CmdletBinding()]
param([string]$Out = (Join-Path $PSScriptRoot 'package'))
$ErrorActionPreference='Stop'
$Out=[IO.Path]::GetFullPath($Out)
[void][IO.Directory]::CreateDirectory($Out)
$Compiler=Join-Path $env:SystemRoot 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$Framework=Split-Path $Compiler
$Source=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'MatchaHelper.cs'))
$Backend=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'backend.ps1'))
$Installer=[IO.File]::ReadAllText((Join-Path $PSScriptRoot 'install.ps1'))
$Build=[IO.File]::ReadAllText($PSCommandPath)
$Readable="MATCHA HELPER 1.1.1 — COMPLETE SOURCE`r`n`r`n===== MatchaHelper.cs =====`r`n"+$Source+"`r`n===== backend.ps1 =====`r`n"+$Backend+"`r`n===== install.ps1 =====`r`n"+$Installer+"`r`n===== build.ps1 =====`r`n"+$Build
[IO.File]::WriteAllText((Join-Path $Out 'source-code.txt'),$Readable,[Text.UTF8Encoding]::new($false))
Add-Type -AssemblyName System.Drawing
$Bitmap=[Drawing.Bitmap]::new(32,32); $Graphics=[Drawing.Graphics]::FromImage($Bitmap)
$Graphics.SmoothingMode='AntiAlias'; $Brush=[Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(160,225,193))
$Graphics.FillEllipse($Brush,3,12,24,15)
$Graphics.FillPolygon($Brush,[Drawing.Point[]]@([Drawing.Point]::new(24,20),[Drawing.Point]::new(29,7),[Drawing.Point]::new(31,13),[Drawing.Point]::new(29,23)))
$Graphics.FillRectangle($Brush,11,6,2,7); $Graphics.FillEllipse($Brush,8,4,5,3); $Graphics.FillEllipse($Brush,13,3,5,3)
$Eye=[Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(14,18,16)); $Graphics.FillEllipse($Eye,8,17,3,3)
$Icon=[Drawing.Icon]::FromHandle($Bitmap.GetHicon()); $File=[IO.File]::Create((Join-Path $Out 'matcha.ico')); $Icon.Save($File); $File.Close()
$Graphics.Dispose(); $Bitmap.Dispose(); $Brush.Dispose(); $Eye.Dispose(); $Icon.Dispose()
& $Compiler /nologo /target:winexe /optimize+ /platform:anycpu "/out:$Out\matcha-helper.exe" "/win32icon:$Out\matcha.ico" "/reference:$Framework\System.Windows.Forms.dll" "/reference:$Framework\System.Drawing.dll" "/reference:$Framework\System.Web.Extensions.dll" "/reference:$Framework\Microsoft.VisualBasic.dll" "/resource:$PSScriptRoot\backend.ps1,Backend" "/resource:$Out\source-code.txt,Source" "/resource:$PSScriptRoot\install.ps1,Installer" "/resource:$PSScriptRoot\README.txt,Readme" "$PSScriptRoot\MatchaHelper.cs"
if($LASTEXITCODE -ne 0){throw 'native compilation failed'}
foreach($name in @('README.txt','install.ps1','MatchaHelper.cs','backend.ps1','build.ps1')) { Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $Out $name) -Force }
[IO.File]::WriteAllText((Join-Path $Out 'uninstall.cmd'),"@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0install.ps1`" -Uninstall`r`npause`r`n")
$Hashes=Get-ChildItem -LiteralPath $Out -File | Where-Object Name -ne 'SHA256SUMS.txt' | Sort-Object Name | ForEach-Object { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLower()+'  '+$_.Name }
[IO.File]::WriteAllLines((Join-Path $Out 'SHA256SUMS.txt'),$Hashes)
Write-Output ('built '+(Join-Path $Out 'matcha-helper.exe'))
