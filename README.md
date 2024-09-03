# .bash_aliases
Useful prompt and functions to make live easier on Cloudways servers. Yes, I know we shouldnt use `.bash_aliases` for all these additional functionality. However, `.bash_aliases` is included automatic by the default Clouways `.bashrc`. So we do not have to do any editing, just drop this file in your `~` home.

`PROMPT_COMMAND` is used to check the timestamp of `.bash_aliases` on each prompt reload. If its a new timestamp `.bashrc` is re-sourced. This will make sure all screen prompts and `.bash_aliases` are updated when required.

Makes sure that `screen -R` is loaded in non-screen bash to avoid multiple sceeen sessions. Screen itself has enough windows available. Also, it makes sure that `exit` is remapped to `screen -D` to make sure the screen and all windows are not accidently closed when using the exit command.

## Prompt
- Screen # and title
- Github branch (dirty *)

## Screen
- Add `screen -X` vars to avoid messages blocking and appearing
  - This is necesarry to make `screen -Q title` work

# aliases

### `lt`
Nice way to show folder content

### `getgitbash`
Retrieve new `.bash_aliases` from github

### `screenlist`
Returns the current list of screens # and titles

### `apm`
Shortversion for `/usr/local/sbin/apm`

# APM
Server and application information:
`/usr/local/sbin/apm`

Application information traffix by timeframe
`/usr/local/sbin/apm -s juseyhuctm traffic -l 2m`

## Available Commands

### `bandwidth`
Get application and url network bandwidth

### `cron`
Report running crons for a specific application

### `domains`
Get list of application primary domains

### `help`
Help about any command

### `info`
Get Cloudways platform server

### `mysql`
MySQL related statistics

### `php`
Php processes related statistics

### `scan`
Scan server for any suspicious files

### `traffic`
Web traffic based statistics

### `upgrade`
Auto upgrade this tool

### `users`
Get list of app and master user

### `version`
Prints version information

