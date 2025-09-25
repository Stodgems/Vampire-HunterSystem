param(
    [string]$Root = "v-vh-system\lua"
)

function Remove-LuaComments {
    param([string]$Text)

    $len = $Text.Length
    $i = 0
    $sb = New-Object System.Text.StringBuilder

    $state = 'code'           # code | string | longstring | longcomment
    $strDelim = ''
    $longEq = 0

    while ($i -lt $len) {
        $ch = $Text[$i]
        switch ($state) {
            'code' {
                if ($ch -eq '"' -or $ch -eq "'") {
                    $state = 'string'
                    $strDelim = $ch
                    [void]$sb.Append($ch)
                    $i++
                    break
                }
                if ($ch -eq '[') {
                    # Check for long string start [=*[ ... ]=*]
                    $j = $i + 1
                    $eqCount = 0
                    while ($j -lt $len -and $Text[$j] -eq '=') { $eqCount++; $j++ }
                    if ($j -lt $len -and $Text[$j] -eq '[') {
                        $state = 'longstring'
                        $longEq = $eqCount
                        [void]$sb.Append($Text.Substring($i, ($j - $i) + 1))
                        $i = $j + 1
                        break
                    }
                }
                if ($ch -eq '-' -and ($i + 1) -lt $len -and $Text[$i + 1] -eq '-') {
                    # Comment: line or block?
                    $j = $i + 2
                    if ($j -lt $len -and $Text[$j] -eq '[') {
                        $k = $j + 1
                        $eqCount = 0
                        while ($k -lt $len -and $Text[$k] -eq '=') { $eqCount++; $k++ }
                        if ($k -lt $len -and $Text[$k] -eq '[') {
                            # Long comment --[=*[ ... ]=*]
                            $state = 'longcomment'
                            $longEq = $eqCount
                            $i = $k + 1
                            break
                        }
                    }
                    # Line comment: skip to end of line (preserve newline)
                    while ($i -lt $len -and $Text[$i] -ne "`n") { $i++ }
                    # do not append the comment text; just continue so newline is processed normally
                    break
                }
                [void]$sb.Append($ch)
                $i++
                break
            }
            'string' {
                [void]$sb.Append($ch)
                if ($ch -eq '\\') {
                    if ($i + 1 -lt $len) {
                        [void]$sb.Append($Text[$i + 1])
                        $i += 2
                    } else {
                        $i++
                    }
                    break
                }
                if ($ch -eq $strDelim) {
                    $state = 'code'
                    $i++
                    break
                }
                $i++
                break
            }
            'longstring' {
                if ($ch -eq ']') {
                    $j = $i + 1
                    $eqCount2 = 0
                    while ($j -lt $len -and $Text[$j] -eq '=') { $eqCount2++; $j++ }
                    if ($eqCount2 -eq $longEq -and $j -lt $len -and $Text[$j] -eq ']') {
                        [void]$sb.Append($Text.Substring($i, ($j - $i) + 1))
                        $i = $j + 1
                        $state = 'code'
                        break
                    }
                }
                [void]$sb.Append($ch)
                $i++
                break
            }
            'longcomment' {
                if ($ch -eq ']') {
                    $j = $i + 1
                    $eqCount2 = 0
                    while ($j -lt $len -and $Text[$j] -eq '=') { $eqCount2++; $j++ }
                    if ($eqCount2 -eq $longEq -and $j -lt $len -and $Text[$j] -eq ']') {
                        # End of long comment
                        $i = $j + 1
                        $state = 'code'
                        break
                    }
                }
                $i++
                break
            }
        }
    }

    return $sb.ToString()
}

$rootPath = Resolve-Path $Root
$luaFiles = Get-ChildItem -Path $rootPath -Recurse -Filter *.lua | Sort-Object FullName
foreach ($f in $luaFiles) {
    $orig = Get-Content -Raw -LiteralPath $f.FullName
    $clean = Remove-LuaComments -Text $orig
    if ($clean -ne $orig) {
        Set-Content -LiteralPath $f.FullName -Value $clean -NoNewline
        Write-Host "Stripped comments:" $f.FullName
    } else {
        Write-Host "No changes:" $f.FullName
    }
}
