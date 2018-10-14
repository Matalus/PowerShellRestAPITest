#PowerShell Restful API

$ErrorActionPreference = "Stop"

#Auto Elevation
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    Write-Host "Elevating Prompt..."
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

#Define location and set
$RunDir = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $RunDir

#Load Functions library
Write-Host  "$(Get-Date -Format u) | Loading Function Library"
Remove-Module functions -ErrorAction SilentlyContinue
Set-Location $RunDir
Import-Module ".\functions" -DisableNameChecking

#Stop previous listener if still running
if ($listener) {
    $listener.Stop()
}

#Listen on localhost port 8000
Log "Starting Listener"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://+:8000/')
$listener.Start()

Log "Listening for Requests on port 8000"


#Execution Loop
WHILE ($true) {
    $context = $listener.GetContext()

    #Capture context details
    $request = $context.Request

    #Setup Response
    $response = $context.Response

    #Break Loop if GET request sent to /end
    if ($request.Url -match '/end$') {
        break
    }
    else {


        #Split URL to get command and options
        $requestvars = $request.Url -split "/"

        if ($requestvars[3] -eq "wmi") {
            "";Log "Request Received: $($request.Url)"
            Log "Processing WMI Query..."
            #Get the class and server name and run get-wmiobject
            $params = @{
                class    = $requestvars[4]
                computer = $requestvars[5] 
            }
            
            $ErrorCount = 0
            $Error.Clear()
            Try {
                $result = Get-WmiObject @params
            }
            Catch {
                $ErrorCount++
                $result = [pscustomobject]@{
                    #Message = RNGTopGun
                    Message = RNGFlavorTown
                    Error = $Error[0].toString()
                    Params = $params
                    InvocationInfo = $Error[0].InvocationInfo.line.trimStart()
                    ErrorDetails = $Error[0]
                }
                
            }

            if ($ErrorCount -ge 1) {

                $message = $result | ConvertTo-Json | Format-Json
                $response.ContentType = 'application/json'
                "";Log "Error: $($result.Error)"
                Log "$($result.Message)"
            }
            else {
                $message = $result | ConvertTo-Json | Format-Json
                $response.ContentType = 'application/json'
                "";Log "Found $($result.count) objects - responding...";""
            }

        }
        else {

            #no match
            $message = "This is not the API you're looking for *waves hand*"
            $response.ContentType = 'text/html'
        }

        #convert to UTF8
        $message = $message.Replace("\u0027","'")
        [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
        #Set response length
        $response.ContentLength64 = $buffer.Length

        #Write Response 
        $Output = $response.OutputStream
        $Output.Write($buffer, 0, $buffer.Length)
        $Output.Close()
    }
}

#Log "Stopping Listener on port 8000"
#$listener.Stop()



