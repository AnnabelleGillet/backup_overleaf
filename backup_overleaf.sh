#!/bin/bash
now=`date +"%Y-%m-%d"`
directory=~/Documents/Scripts/Overleaf/backup
outputTmpDirectory=$directory/tmp.zip
outputDirectory=$directory/$now.zip

# To get the cookie
cookie=`python - << EOF
import re
# pip install mechanize
from mechanize import Browser

# To get the backup directly from the official Overleaf
cookie_name = "overleaf_session2"
# To get the backup from a private Overleaf server
#cookie_name = "sharelatex.sid"

login = "login"
password = "password"

br = Browser()
br.set_handle_robots(False)
br.open("https://www.overleaf.com/login")
br.select_form('loginForm')
br.form['email'] = login
br.form['password'] = password
br.submit()

# if successful we have some cookies now
cookies = br._ua_handlers['_cookies'].cookiejar
# convert cookies into a dict usable by requests
cookie_dict = {}
cookie = cookie_name
for c in cookies:
	if c.name == cookie_name:
		cookie += "=" + c.value
	cookie_dict[c.name] = c.value
print(cookie)
EOF`
cookie="Cookie: "$cookie

# Get the list of projects
IN=`curl 'https://www.overleaf.com/project' --compressed -H "$cookie" | grep "application/json"`
# Extract the JSON with the list of projects
delimiter="<script id=\"data\" type=\"application/json\">"
IN=${IN#*"$delimiter"}
json="${IN%%"$delimiter"*}"
# Get the ids of the projects
projectIds=$(echo $json | grep -Po '"id":.*?[^\\]",' | tr -d "\"" | tr -d "," | awk -F':' '{print $2}')
projectIds=$(echo $projectIds | tr " " ",")

# Download the zip
code=$(curl "https://www.overleaf.com/project/download/zip?project_ids=$projectIds" --compressed -H "$cookie" -w "%{http_code}" --output $outputTmpDirectory)

if [ "$code" -eq 200 ] ; then
	cp $outputTmpDirectory $outputDirectory
fi
