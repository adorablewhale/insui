# Install the optional Matcha Windows helper for this user. No administrator rights needed.
[CmdletBinding()]
param([switch]$Uninstall, [string]$Workspace = 'C:\matcha\workspace')
$ErrorActionPreference = 'Stop'
$InstallRoot = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'matcha-helper'))
$StartupRoot = [Environment]::GetFolderPath('Startup')
$ShortcutPath = Join-Path $StartupRoot 'Matcha helper.lnk'
$PidFile = Join-Path $InstallRoot 'process.json'
$PowerShellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$RunnerPath = Join-Path $InstallRoot 'run.ps1'

function Assert-ManagedPath([string]$Path) {
  $full = [IO.Path]::GetFullPath($Path)
  if ($full -ne $InstallRoot -and -not $full.StartsWith($InstallRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'path outside helper installation' }
  $cursor = $full
  while ($cursor -and (Test-Path -LiteralPath $cursor)) {
    if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'linked installation paths are not supported' }
    $parent = [IO.Path]::GetDirectoryName($cursor)
    if ($parent -eq $cursor) { break }; $cursor = $parent
  }
}
function Stop-InstalledHelper {
  if (-not (Test-Path -LiteralPath $PidFile)) { return }
  $saved = Get-Content -LiteralPath $PidFile -Raw | ConvertFrom-Json
  $process = Get-CimInstance Win32_Process -Filter ('ProcessId=' + [int]$saved.pid) -ErrorAction SilentlyContinue
  # PID reuse must never stop an unrelated PowerShell process.
  if ($process -and $process.Name -ieq 'powershell.exe' -and $process.CommandLine -and
      $process.CommandLine.IndexOf('"' + $RunnerPath + '"', [StringComparison]::OrdinalIgnoreCase) -ge 0 -and
      $process.CreationDate.ToUniversalTime().Ticks -eq [long]$saved.created) {
    Stop-Process -Id $process.ProcessId -ErrorAction Stop
    $beatFile = Join-Path ([string]$saved.workspace) 'INSUI\helper\helper.json'
    if (Test-Path -LiteralPath $beatFile) {
      $beat = Get-Content -LiteralPath $beatFile -Raw | ConvertFrom-Json
      if ([int]$beat.pid -eq [int]$saved.pid) { $beat.beat = 0; $beat | ConvertTo-Json -Compress | Set-Content -LiteralPath $beatFile -Encoding UTF8 }
    }
  }
}
function Recycle([string]$Path) {
  if (Test-Path -LiteralPath $Path) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path, 'OnlyErrorDialogs', 'SendToRecycleBin')
  }
}
Assert-ManagedPath $InstallRoot
foreach ($name in @('run.ps1','matcha-helper.bat','install.ps1','process.json','workspace.txt')) { Assert-ManagedPath (Join-Path $InstallRoot $name) }
if ($Uninstall) {
  Stop-InstalledHelper
  # Remove only this installer's shortcut and files. Unknown files are preserved.
  if (Test-Path -LiteralPath $ShortcutPath) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($ShortcutPath)
    if ($shortcut.Arguments.IndexOf('"' + $RunnerPath + '"', [StringComparison]::OrdinalIgnoreCase) -lt 0) { throw 'startup shortcut belongs to another application' }
    Recycle $ShortcutPath
  }
  foreach ($name in @('run.ps1','matcha-helper.bat','install.ps1','process.json','workspace.txt')) { Recycle (Join-Path $InstallRoot $name) }
  Write-Output 'helper uninstalled; managed files moved to the recycle bin'
  return
}
$Workspace = [IO.Path]::GetFullPath($Workspace)
if (-not (Test-Path -LiteralPath $Workspace -PathType Container)) { throw 'Matcha workspace folder not found' }
$Source = Join-Path $PSScriptRoot 'matcha-helper.bat'
if (-not (Test-Path -LiteralPath $Source)) { throw 'keep install.ps1 beside matcha-helper.bat' }
Stop-InstalledHelper
if (Get-NetTCPConnection -LocalPort 47210 -State Listen -ErrorAction SilentlyContinue) { throw 'another helper is already running; close its window, then install again' }
[void][IO.Directory]::CreateDirectory($InstallRoot)
if ([IO.Path]::GetFullPath($Source) -ne (Join-Path $InstallRoot 'matcha-helper.bat')) { Copy-Item -LiteralPath $Source -Destination (Join-Path $InstallRoot 'matcha-helper.bat') }
if ($PSCommandPath -ne (Join-Path $InstallRoot 'install.ps1')) { Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $InstallRoot 'install.ps1') }
[IO.File]::WriteAllText((Join-Path $InstallRoot 'workspace.txt'), $Workspace)
$Runner = @'
$ErrorActionPreference = 'Stop'
$env:FH_SELF = Join-Path $PSScriptRoot 'matcha-helper.bat'
$env:FH_ARG = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'workspace.txt'))
$env:MATCHA_HELPER_NO_BROWSER = '1'
$own = Get-CimInstance Win32_Process -Filter ('ProcessId=' + $PID)
@{pid=$PID; created=$own.CreationDate.ToUniversalTime().Ticks; workspace=$env:FH_ARG} | ConvertTo-Json -Compress | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'process.json') -Encoding UTF8
Invoke-Expression ([IO.File]::ReadAllText($env:FH_SELF))
'@
[IO.File]::WriteAllText($RunnerPath, $Runner)
$Arguments = '-STA -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + $RunnerPath + '"'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $PowerShellExe; $shortcut.Arguments = $Arguments
$shortcut.WorkingDirectory = $InstallRoot; $shortcut.WindowStyle = 7
$shortcut.Description = 'Optional Matcha helper: localhost only; uninstall with install.ps1 -Uninstall'
$shortcut.Save()
Start-Process -FilePath $PowerShellExe -ArgumentList $Arguments -WindowStyle Hidden
Write-Output 'helper installed and started hidden; starts at login for this user'
Write-Output ('uninstall: powershell -NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $InstallRoot 'install.ps1') + '" -Uninstall')
