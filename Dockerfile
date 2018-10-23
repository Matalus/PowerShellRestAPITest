FROM microsoft/powershell

EXPOSE 8000

COPY functions.psm1 c:\\functions.psm1
COPY server.ps1 c:\\server.ps1
COPY star_wars_quotes.json c:\\star_wars_quotes.json
COPY top_gun_quotes.json c:\\top_gun_quotes.json
COPY guy_fieri_quotes.json c:\\guy_fieri_quotes.json

CMD ["powershell.exe", "c:\\server.ps1"]