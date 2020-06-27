# Backup of an Overleaf account's projects
A bash script to download all the projects of an Overleaf account. It has a dependency to the python module mechanize.
```
pip install mechanize
```
It first log in to Overleaf with the python module, then gets the cookie and uses it to download the zip containing all the source files of the projects. The script is writen to save the zip with the date of the day as name, but doesn't do it if the download is not successful.

Some parameters can be adapted in the script:
- The directory where to download the zip, at line 3
- The login and password of the user, at lines 13 and 14
