# .bash_aliases
Useful prompt and functions to make live easier on Cloudways servers

# Prompt
- Screen # and title
- Github branch (dirty *)

# Screen
- Add `screen -X` vars to avoid messages blocking and appearing
  - This is necesarry to make `screen -Q title` work

# APM
Server and application information:
`/usr/local/sbin/apm`

Application information traffix by timeframe
`/usr/local/sbin/apm -s juseyhuctm traffic -l 2m`

## Available Commands
- bandwidth   Get application and url network bandwidth
- cron        Report running crons for a specific application
- domains     Get list of application primary domains
- help        Help about any command
- info        Get Cloudways platform server
- mysql       MySQL related statistics
- php         Php processes related statistics
- scan        Scan server for any suspicious files
- traffic     Web traffic based statistics
- upgrade     Auto upgrade this tool
- users       Get list of app and master user
- version     Prints version information

