#Library of functions

#logs messages to console
Function Log($message) {
    "$(Get-Date -Format u) | $message"
}
Export-ModuleMember Log
#Instead of an error message generates random Top Gun Quotes
Function RNGTopGun () {
    $Quotes = @(
        "You can be my wingman any time.",
        "She's lost that loving feeling.",
        "Great, then I wont have to worry about you making your living as a singer.",
        "Im going to need a beer to put these flames out.",
        "No. No, Mav, this is not a good idea.",
        "You up for this one, Maverick?",
        "That was some of the best flying I've seen to date right up to the part where you got killed.",
        "Just a walk in the park, Kazansky.",
        "You don't have time to think up there. If you think, you're dead.",
        "BALLISTIC MISSILE THREAT INBOUND TO HAWAII. SEEK IMMEDIATE SHELTER. THIS IS NOT A DRILL.",
        "Let's turn and burn!",
        "What's your problem, Kazansky?",
        "His fitness report says it all. Flies by the seat of his pants, totally unpredictable.",
        "It takes a lot more than just fancy flying.",
        "You're not going to be happy unless you're going Mach 2 with your hair on fire."
    )

    $RNGparams = @{
        Minimum = 0
        Maximum = $Quotes.Length - 1
    }   
    
    $RNG = Get-Random @RNGparams
    $Quotes[$RNG]
}
Export-ModuleMember RNGTopGun

Function RNGFlavorTown () {
    $Quotes = @(
        "Peace love and taco grease",
        "I don't know if it's fair to call their Russian dressing Russian dressing it should be called something sexy, like liquid Moscow",
        "They make a porchetta that you won't forgetta",
        "You can find that dictionary in the Flavourtown library.",
        "If it tastes really good and it's funky, it's funkalicious.",
        "That deep fryer looks like the community pool in Flavourtown.",
        "That's the definition of stupid in Flavourtown. Stupid in a good way.",
        "Splash some rub around the rest of the hog for good measure. This really doesn't do a dang thing, but it makes you feel good about things and makes for good drama.",
        "I've always been an eccentric, a rocker at heart. I can't play the guitar, but I can play the griddle.",
        "His seafood is so fresh it'll slap ya!"
    )

    $RNGparams = @{
        Minimum = 0
        Maximum = $Quotes.Length - 1
    }   
    
    $RNG = Get-Random @RNGparams
    $Quotes[$RNG]
}
Export-ModuleMember RNGFlavorTown


function Format-Json([Parameter(Mandatory, ValueFromPipeline)][String] $json) {
    $indent = 0;
    ($json -Split '\n' |
      % {
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