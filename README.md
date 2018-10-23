# PowerShellRestAPITest

execute server.ps1 to start server by default listens on port 8000, can be reconfigured by changing $ListenPort variable in script

to launch in docker execute: 
    "docker build -t psrest ."
    "docker run -p 8000:8000 -h psrest --name ps_serv psrest"

Commands:

/starwars   -- generates random star wars quote
/topgun     -- generates random top gun quote
/flavortown -- generates random guy fieri quote
/stop       -- remotely stops listener
