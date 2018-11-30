#Library of functions

#logs messages to console
Function Log($message) {
    "$(Get-Date -Format u) | $message"
}
Export-ModuleMember Log

#Generates random quotes from seed file
Function RNGQuoteGen ($quote_seed) {
    $Quotes = $quote_seed

    $RNGparams = @{
        Minimum = 0
        Maximum = $Quotes.Length - 1
    }   
    
    $RNG = Get-Random @RNGparams
    $Quotes[$RNG]
}
Export-ModuleMember RNGQuoteGen


function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split '\n' |
      ForEach-Object {
        if ($_ -match '[\}\]]') {
          # This line contains  ] or }, decrement the indentation level
          $indent--
        }
        $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
        if ($_ -match '[\{\[]') {
          # This line contains [ or {, increment the indentation level
          $indent++
        }
        $line
    }) -Join "`n"
  }
  Export-ModuleMember Format-Json

Function GenToken($Length){
    #Generate Alpha Number Chars    
    $Alpha = @() 
    65..90 | ForEach-Object{
        $Alpha += [char]$_        
    }
    $Numeric = 0..9
    [array]$AlphaNumeric = $Alpha + $Numeric
     
    [string]$Token = ""
    For($x=0; $x -le $Length; $x++){
        $Token += $AlphaNumeric[(Get-Random -Minimum 0 -Maximum $AlphaNumeric.Length)]
    }
    Return $Token
 }

 Export-ModuleMember GenToken