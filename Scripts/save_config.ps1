$f = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\config.ini"))
$k = $env:SAVE_KEY
$v = $env:SAVE_VAL
$out = (Get-Content $f) | ForEach-Object {
    if ($_ -like ($k + '=*')) { $k + '=' + $v } else { $_ }
}
[System.IO.File]::WriteAllLines($f, $out, (New-Object System.Text.UTF8Encoding $false))
