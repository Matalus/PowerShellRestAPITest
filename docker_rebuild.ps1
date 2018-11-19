Function Log($message) {
   "$(Get-Date -Format u) | $message"
}

Log "Stopping Running Container..."
docker stop ps_serv --time 10

Log "Pruning old containers..."
docker system prune -f

Log "Rebuilding Container..."
docker build -t psrest .

Log "Running Container..."
docker run --detach --publish 8000:8000 -h psrest --name ps_serv psrest