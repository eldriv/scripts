# This repository contain end-session script which has an option of hibernate and suspend. 

# End session script
Instead of manually typing:
```shell
$ sudo systemctl hibernate
$ sudo systemctl suspend
```
You can just type it with number by choosing through its options:
```
nycto krad ~ 
$ end-session -e
Choose an option (1-3) 
 1) Hibernate
 2) Suspend
 3) Exit
 ► : 2
[sudo] password for nycto: 

$ end-session -h
Usage: end-session [OPTIONS]

Options:
-h, --help       Display this help message.
-d, --debug      Enable debug mode.
-v, --verbose    Enable verbose output.
-e, --end    End session.
Choose the following:
1) Hibernate
2) Suspend
3) Exit

$ end-session -k
Error: Invalid command '-k'. Please see 'end-session --help.'

```
Instead using **$ ./end-session** to run the script in NixOS shell make sure to export your script's directory into $HOME, inside the ~/.zshenv add this snippet: **export PATH="$HOME/script:$PATH"** in that case now you can run it just **$ end-session**
