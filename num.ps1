<#
.SYNOPSIS
    Net Uptime Monitor
.DESCRIPTION
    A PowerShell script that tests for internet connectivity by pinging three external addresses.  When all three fail, a FAIL event triggers in the log file.
.EXAMPLE
    ./num.ps1
    Invokes the script
.INPUTS
    None, presently.
.OUTPUTS
    Log File:  C:\Windows\Temp\NUM_<date>.log
.NOTES
    Version: 1.1
    Creation Date: 8/28/2020

    Updates:
    8/28/2020: v1.0 - Initial Script
    8/28/2020: v1.1 - Added Outage Timer

    TODOs:
    - Make IP entry fields restricted to text in address form only
    - Clean up remarks
    - Turn into a function
    - Add Params
#>

#function start-num {
#param() #None defined at this time

Add-Type -AssemblyName PresentationCore,PresentationFramework #Library used for the display of Popup Notifications

#Default Settings
$test1 = "8.8.8.8" #Google DNS
$test2 = "208.67.222.222" #OpenDNS
$test3 = "1.1.1.1" #Cloudflare DNS
$delay = "30" #Delay, in seconds
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$silent = $true

#Log File Creation
$filepath = "C:\windows\temp\"
$todaysdate = Get-Date
$filedate = Get-Date -Format MMddyyyy
$filename = "NUM_" + $filedate + ".log"
$fullpath = $filepath + $filename
New-Item -Path $filepath -Name $filename -ItemType "file"
Write-Output "Network Uptime Monitor" | Out-File -FilePath $fullpath
Write-Output $todaysdate | Out-File -FilePath $fullpath -Append
Write-Output "" | Out-File -FilePath $fullpath -Append
Write-Output "" | Out-File -FilePath $fullpath -Append
Write-Output "Starting monitoring..." | Out-File -FilePath $fullpath -Append
Write-Output "" | Out-File -FilePath $fullpath -Append

#
#
function get-results{
    $count = 0
    Get-Date | Out-File -FilePath $fullpath -Append
    $result1 = Test-Connection -TargetName $test1 -Count 1
    $result2 = Test-Connection -TargetName $test2 -Count 1
    $result3 = Test-Connection -TargetName $test3 -Count 1

    Clear-Host
    $resultdate = Get-Date
    $resultdate
    $result1 | Select-Object Destination,Latency,Status | Format-Table *
    $result2 | Select-Object Destination,Latency,Status | Format-Table *
    $result3 | Select-Object Destination,Latency,Status | Format-Table *
    
    $result1 | Select-Object Destination,Latency | Format-Table -HideTableHeaders | Out-File -FilePath $fullpath -Append
    $result2 | Select-Object Destination,Latency | Format-Table -HideTableHeaders | Out-File -FilePath $fullpath -Append
    $result3 | Select-Object Destination,Latency | Format-Table -HideTableHeaders | Out-File -FilePath $fullpath -Append
    Write-Output "" | Out-File -FilePath $fullpath -Append
    
    If ($result1.Latency -eq "0"){
        $count++}
    If ($result2.Latency -eq "0"){
        $count++}
    If ($result3.Latency -eq "0"){
        $count++}
    
    If ($count -lt 3 -and $stopwatch.isrunning -eq $true){
        $stopwatch.stop()
        Write-Output "" | Out-File -FilePath $fullpath -Append
        Write-Output "**Service Restored**" | Out-File -FilePath $fullpath -Append
        Write-Output "Total outage time, for this instance was:" | Out-File -FilePath $fullpath -Append
        Write-Output $stopwatch.elapsed | Out-File -FilePath $fullpath -Append
        Write-Output "" | Out-File -FilePath $fullpath -Append
        $stopwatch.reset()
    }
        
    If ($count -eq 3){
        If (!$silent){
            $errordate = Get-Date
            [System.Windows.MessageBox]::Show("Outage detected on " + $errordate + ".")}
        If (!$stopwatch.isrunning){
            $stopwatch.start()}

            $errordate = Get-Date
            Write-Host "*****Outage Detected on " + $errordate + ".*****"
            Write-Output "*****Outage Detected on " +  $errordate + ".*****" | Out-File -FilePath $fullpath -Append
            Write-Output "" | Out-File -FilePath $fullpath -Append
        } #End COUNT Loop
    } #End Get-Results Function
#
#

Clear-Host
Write-Host "Welcome to Net Uptime Monitor - Powershell Edition"
Write-Host ""
Write-Host "The default ping targets are: 8.8.8.8 (Google DNS), 208.67.222.222 (OpenDNS), and 1.1.1.1 (CloudFlare DNS)"
Write-Host ""
Write-Host "Please specify your first ping target:  (Press ENTER to accept the default, Google DNS)"
$question1 = Read-Host

If ($question1 -eq ""){
    $test1 = "8.8.8.8"
}    else {
    $test1 = $question1
} #End IF loop

Write-Host ""
Write-Host ""
Write-Host "Please specify your second ping target:  (Press ENTER to accept the default, OpenDNS)"
$question2 = Read-Host

If ($question2 -eq ""){
    $test2 = "208.67.222.222"
}    else {
    $test2 = $question2
} #End IF loop

Write-Host ""
Write-Host ""
Write-Host "Please specify your third ping target:  (Press ENTER to accept the default, Cloudflare DNS)"
$question3 = Read-Host

If ($question3 -eq ""){
    $test3 = "1.1.1.1"
}    else {
    $test3 = $question3
} #End IF loop

Write-Host ""
Write-Host ""
Write-Host "How long between tests?  (In Seconds)"
$delay = Read-Host

#Clear-Host
#Write-Host "What level of logging do you want? (Log files located at c:\windows\temp\num.log)"
#Write-Host "1. All ping results"
#Write-Host "2. Just Connectivity Failures"
#Write-Host ""
#$logging = Read-Host

#If ($logging -eq "1"){
#    $logging = $true
#} else {
#    $logging = $false
#} #End IF loop

Clear-Host
Write-Host "Would you like an immediate notification of a connection failure?  (Pop-up)"
Write-Host "**NOTE** Outage detection will pause while Pop-Up is Visible."
Write-Host "1. Yes / 2. No"
Write-Host ""
$popup = Read-Host

If ($popup -eq "1"){
    $silent = $false
} else {
    $silent = $true
} #End IF loop

Clear-Host
$wait = $true
While ($wait){
    get-results
    Start-Sleep -Seconds $delay
}

# } #End FUNCTION start-num

# SIG # Begin signature block
# MIIFmgYJKoZIhvcNAQcCoIIFizCCBYcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSp393Y68r6E+3L3b3lH8pwXY
# DuygggMmMIIDIjCCAgqgAwIBAgIQPoYj+u2i2rxKYBvqoAhkiDANBgkqhkiG9w0B
# AQsFADApMScwJQYDVQQDDB5LZXZpbiBMb2NrZW15IC0gQ29kZSBTaWduIENlcnQw
# HhcNMTkxMTIwMjAzMDU0WhcNMjAxMTIwMjA1MDU0WjApMScwJQYDVQQDDB5LZXZp
# biBMb2NrZW15IC0gQ29kZSBTaWduIENlcnQwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQC4w9x8FDimdIVVygdL+X6rIYMEHRYSF/ajUclbmbZqSlvjor/T
# pgux9V1aAbri+CGH1vrEkB+3irnMLi72HtXeFQrIVXXtikQWpzzMemujUpvB+0aR
# FbkAZX8jRLLrwfDupufb4f8a3w6pE/KhWvEoVFEhGJEcmWbWH0ZAtOF5k+0/o+uD
# w5u7fmcP7ik7uKG1ANNfWuV4Yb3uVqNNR5sIwxEoatlBvvwU/1zuO+hL3kO8T7Ub
# bEktK3CBR3uTalo3gKiK8ySWfcHRJVddj9IUaY2sZSVWvBxdqZD+unt1bv7sTEuW
# rH3xZ6Qd1O09ayXx2ezyAZEgx0mm0CRDNX6BAgMBAAGjRjBEMA4GA1UdDwEB/wQE
# AwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUgQ+IyWpKb11TliYj
# TtyTvHsJXxswDQYJKoZIhvcNAQELBQADggEBAEty26jQ+89DIAHKymMq068lGfZf
# nty8ZExl9SeY4iMk5A5SeA8pT0EzfGYTKgSjWbHY9uyDDRqjbpNkea/aEI0b+KR1
# apj5WvDcdF2r84d4p8nl4uDkWOdoJRnydrAUJRaY/BSsusGrL9W5rVsOiLS1E5VT
# vjXdm21AhGD/DX87gO2sWrZ+Ysg/img+s/KmXMdDVVMaQw99JZO+Ugh6OzaObyxX
# JuH/m1yIwBf8rduwsm4vFLW4zkpZm0j7BnyeUYrqg0Y8KE5srEmwYDgOd1IDCnwh
# uFa11HktSogH4gZEUv+qb5KU2pIo4WRnKwCe2C5T4FhedeVqmoLpgrIasyYxggHe
# MIIB2gIBATA9MCkxJzAlBgNVBAMMHktldmluIExvY2tlbXkgLSBDb2RlIFNpZ24g
# Q2VydAIQPoYj+u2i2rxKYBvqoAhkiDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUVQn2PCfdVhRi
# MFD2ISaUxeVtj+8wDQYJKoZIhvcNAQEBBQAEggEATU9VbbcWI02bm+rsbCk/Vxx8
# XZi3sfVhmPjibL/i6BD0LlKUKWx00f9k22eFu9Rld91bg1euk+zrgXcp0EbC3oDP
# pZp3P5DTFt/P1aJIwCFCRiY3XyhcaItrL4J1KiPMkOem3Ddn9ZCJNuj3ldQuLEUJ
# b+s6YshheEzY8K1mnrDwAiAs5YH6KyKDRnBRS7GHj8p9RGrIoGhp76P//2q2RTdd
# 9uzy5ULoh60W05u+YsSQE1EiF7tOo5EbNwSivXwOuuItUGTBLtvWI8jJ15HynVTr
# aD8Tr61l+EHuqxq/k4ECy7hRJWE6kN85Unm3mNJLhLIUiBQvILeB/YnM3BuqHA==
# SIG # End signature block
