# Automated uFlix logins

uFlix is a Netflix geo-unblocker service.

Before you can use it with your devices, you have to log into their website so
that it knows to authorise your current IP address.

If you're on a service that frequently changes your IP, then this can be annoying,
so I've automated it. I am not affiliated with uFlix at all.

## Installation

```
sudo apt install liblwp-protocol-https-perl
curl -o uflix_login.pl https://raw.githubusercontent.com/TJC/uFlix-Login/master/uflix_login.pl
chmod +x uflix_login.pl
```

## Running it

You must put your uflix username and password into the environment,
so you run it like so:

`UFLIX_USER=johndoe UFLIX_PASS=topsecret ./uflix_login.pl`

I suggest putting it into crontab, such as like this:

`*/10 * * * * UFLIX_USER=johndoe UFLIX_PASS=topsecret /home/username/bin/uflix_login.pl`

## Output and exit codes

If the script is successful, it will output nothing, and have an exit code of 0

If the script fails, it will exit with a non-zero code, and output some info that
might help you determine what went wrong.
