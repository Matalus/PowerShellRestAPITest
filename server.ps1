#PowerShell Restful API

$ErrorActionPreference = "Stop"

#Auto Elevation - Only run on PS Desktop Windows - Don't run on PSCore v6+
if($Host.Version -lt [version]"6.0.0.0"){
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
        Write-Host "Elevating Prompt..."
        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        Break
    }
}
$ListenPort = 8000
#Define location and set
$RunDir = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $RunDir

#Load Functions library
Write-Host  "$(Get-Date -Format u) | Loading Function Library"
Try{
Remove-Module functions -ErrorAction SilentlyContinue
}Catch{$_ | Out-Null}
Set-Location $RunDir
Import-Module ".\functions" -DisableNameChecking

#Stop previous listener if still running
if ($listener) {
    $listener.Stop()
}

#Listen on localhost port provided above
Log "Starting Listener"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$ListenPort/")
$listener.Start()

Log "Listening for Requests on port $ListenPort"

Log "Loading Trival Quote Seeds..."

#Loads Quote seeds
$seeds = Get-ChildItem $RunDir -Filter "*quotes.json"
ForEach ($seed in $seeds) {
    (New-Variable -Name $seed.basename -Force -Value ((Get-Content $seed.Fullname) -join "`n" | ConvertFrom-Json))
    Log "Loaded $($seed.basename)"
}

Log "Generating API Token..."
$Token = GenToken -Length 64
Log "Token = $Token"


#Execution Loop
WHILE ($listener.IsListening) {
    $context = $listener.GetContext()

    #Capture context details
    $request = $context.Request

    #Setup Response
    $response = $context.Response

    #Break Loop if GET request sent to /end
    if ($request.Url -match '/end$') {
        break
    }else {
        #Split URL to get command and options
        $requestvars = $request.Url -split "/"

        if($requestvars[4] -eq $Token){

            if ($requestvars[3] -eq "wmi") {
                Log "Request Received: $($request.Url)"
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
                        $RNG           = Get-Random -Maximum ($seeds.Length - 1)
                        Message        = RNGQuoteGen -quote_seed (Get-Variable -Name $seeds[$RNG].BaseName).Value.quotes
                        Error          = $Error[0].toString()
                        Params         = $params
                        InvocationInfo = $Error[0].InvocationInfo.line.trimStart()
                        ErrorDetails   = $Error[0]
                    }
                    
                }

                if ($ErrorCount -ge 1) {

                    $message = $result | ConvertTo-Json | Format-Json
                    $response.ContentType = 'application/json'
                    Log "Error: $($result.Error)"
                    Log "$($result.Message)"
                }
                else {
                    $message = $result | ConvertTo-Json | Format-Json
                    $response.ContentType = 'application/json'
                    Log "Found $($result.count) objects - responding..."
                }

            }
            elseif ($requestvars[3] -eq "starwars") {
                Log "Request Received: $($request.Url)"
                Log "Generating Star Wars Quote..."
                Try {
                    $result = (RNGQuoteGen($star_wars_quotes.quotes))
                }
                Catch {
                    $ErrorCount++
                    $result = [pscustomobject]@{
                        $RNG           = Get-Random -Maximum ($seeds.Length - 1)
                        Message        = RNGQuoteGen -quote_seed (Get-Variable -Name $seeds[$RNG].BaseName).Value.quotes
                        Error          = $Error[0].toString()
                        Params         = $params
                        InvocationInfo = $Error[0].InvocationInfo.line.trimStart()
                        ErrorDetails   = $Error[0]
                    }
                }
                if ($ErrorCount -ge 1) {

                    $message = $result | ConvertTo-Json | Format-Json
                    $response.ContentType = 'application/json'
                    Log "Error: $($result.Error)"
                    Log "$($result.Message)"
                }else {
                    $message = "<body style='background-color: black;'><table><tr><th style ='font-weight: bold; font-size: 20pt; color: yellow'>" + $result + "</th></tr></table></body>"
                    $response.ContentType = 'text/html'
                    Log "Found $($result.count) objects - responding..."
                    Log "Outputting: $result"
                }
            }
            elseif ($requestvars[3] -eq "topgun") {
                Log "Request Received: $($request.Url)"
                Log "Generating Top Gun Quote..."
                Try {
                    $result = (RNGQuoteGen($top_gun_quotes.quotes))
                }
                Catch {
                    $ErrorCount++
                    $result = [pscustomobject]@{
                        $RNG           = Get-Random -Maximum ($seeds.Length - 1)
                        Message        = RNGQuoteGen -quote_seed (Get-Variable -Name $seeds[$RNG].BaseName).Value.quotes
                        Error          = $Error[0].toString()
                        Params         = $params
                        InvocationInfo = $Error[0].InvocationInfo.line.trimStart()
                        ErrorDetails   = $Error[0]
                    }
                }
                if ($ErrorCount -ge 1) {

                    $message = $result | ConvertTo-Json | Format-Json
                    $response.ContentType = 'application/json'
                    Log "Error: $($result.Error)"
                    Log "$($result.Message)"
                }else {
                    $message = "<body style='background-color: blue;'><table><tr><th style ='font-weight: bold; font-size: 16pt; color: white; text-shadow: -1px -1px 0 red, 1px -1px 0 red,-1px 1px 0 red,1px 1px 0 red;'>" + $result + "</th></tr></table></body>"
                    $response.ContentType = 'text/html'
                    Log "Found $($result.count) objects - responding..."
                    Log "Outputting: $result"
                }
            }elseif ($requestvars[3] -eq "flavortown") {
                Log "Request Received: $($request.Url)"
                Log "Generating Guy Fieri Quote..."
                Try {
                    $result = (RNGQuoteGen($guy_fieri_quotes.quotes))
                }
                Catch {
                    $ErrorCount++
                    $result = [pscustomobject]@{
                        $RNG           = Get-Random -Maximum ($seeds.Length - 1)
                        Message        = RNGQuoteGen -quote_seed (Get-Variable -Name $seeds[$RNG].BaseName).Value.quotes
                        Error          = $Error[0].toString()
                        Params         = $params
                        InvocationInfo = $Error[0].InvocationInfo.line.trimStart()
                        ErrorDetails   = $Error[0]
                    }
                }
                if ($ErrorCount -ge 1) {

                    $message = $result | ConvertTo-Json | Format-Json
                    $response.ContentType = 'application/json'
                    Log "Error: $($result.Error)"
                    Log "$($result.Message)"
                }
                else {
                    $message = "<body style='background-color: red;'><table><tr><th style ='font-weight: bold; font-size: 20pt; color: yellow'>" + $result + "</th></tr></table></body>"
                    $response.ContentType = 'text/html'
                    Log "Found $($result.count) objects - responding..."
                    Log "Outputting: $result"
                }
            }elseif ($requestvars[3] -eq "stop") {
                Log "Received Stop command"
                Log "Unloading Data..."
                ForEach ($var in $seeds) {
                    Remove-Variable $var.basename
                    Log "Removing: $($var.basename)"
                }

                Log "Stopping Listener on port $ListenPort"
                Try {
                    $listener.Stop()
                    Log "server stopped"
                }
                Catch {}

            }else{
                Log "Request Received: $($request.Url)"
                Log "URL Doesn't Match any Functions"

                #no match
                $message = "<body style='background-color: white; text-align: left;'><table>"
                $message += "<tr><th style ='font-weight: bold; font-size: 20pt; color: Red; text-align: left;'>Invalid Command</th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 20pt; color: black; text-align: left;'>This is not the API you're looking for *waves hand*</th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 16pt; color: black; text-align: left;'>Commands:</th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/starwars : generates random Star Wars quote </th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/topgun : generates random Top Gun quote </th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/flavortown : generates random guy fieri quote </th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/stop : stops http listener remotely </th></tr>"
                $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>Tokens are generated on startup and must follow the command, I.E. /starwars/12345</th></tr>"
                $message += "</table>"
                $message += "</body>"
                $response.ContentType = 'text/html'
            }
        }else{
            Log "Request Received: $($request.Url)"
            Log "Invalid Token Submitted"
            #Invalid Token
            $TokenString = $requestvars[4]
            $message = "<body style='background-color: white; text-align: left;'><table>"
            $message += "<tr><th style ='font-weight: bold; font-size: 20pt; color: Red; text-align: left;'>Invalid Token: $TokenString</th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 20pt; color: black; text-align: left;'>This is not the API you're looking for *waves hand*</th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 16pt; color: black; text-align: left;'>Commands:</th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/starwars : generates random Star Wars quote </th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/topgun : generates random Top Gun quote </th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/flavortown : generates random guy fieri quote </th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>/stop : stops http listener remotely </th></tr>"
            $message += "<tr><th style ='font-weight: bold; font-size: 14pt; color: black; text-align: left;'>Tokens are generated on startup and must follow the command, I.E. /starwars/12345</th></tr>"

            $message += "</table>"
            $message += "</body>"
            $response.ContentType = 'text/html'
        }

        if ($listener.IsListening) {
            #convert to UTF8
            $message = $message.Replace("\u0027", "'")
            [byte[]]$buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
            #Set response length
            $response.ContentLength64 = $buffer.Length

            #Write Response 
            $Output = $response.OutputStream
            $Output.Write($buffer, 0, $buffer.Length)
            $Output.Close()
        }
    }
}

#Log "Stopping Listener on port 8000"
#$listener.Stop()



