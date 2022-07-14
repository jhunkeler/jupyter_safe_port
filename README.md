# jupyter_safe_port

```
usage: jupyter_safe_port [-h] [-c] [-d] {host} [port]

Discovers the next TCP port available for your notebook server and returns
execution instructions. If the argument '-c' is present and the requested
port is already bound on the remote host, return the SSH connection string

Positional arguments:
    host    host name or IP of remote system
    port    notebook server port to poll (default: 1024)

Arguments:
    -h    show this usage statement
    -c    only generate the SSH connection string
    -d    dump ports (useful in scripts)
              format: local remote
```

## Install

```
./install.sh --prefix=/usr/local
```

## Examples

_Oh no! I need to run two notebook servers on a remote system but which ports should I use?_

```
$ jupyter_safe_port example.lan
Execute on example.lan:
jupyter notebook --no-browser --port=1024

Connect via:
ssh -N -f -L1024:localhost:1024 user@example.lan
```

You start the first notebook server. Now run `jupyter_safe_port` again...

```
$ jupyter_safe_port example.lan
Execute on example.lan:
jupyter notebook --no-browser --port=1025

Connect via:
ssh -N -f -L1025:localhost:1025 user@example.lan
```

The local port 1024 is already bound to the first server so it gives you 1025. On the remote system, `example.lan`, port 1024 is bound too so it returns 1025 as well. What if you want to use a higher port number on `example.lan`? Let's see...

```
$ jupyter_safe_port example.lan 8080
Execute on example.lan:
jupyter notebook --no-browser --port=8081

Connect via:
ssh -N -f -L1026:localhost:8081 user@example.lan
```

Oops, you forgot about that web server test. 8080 is already bound so you're given 8081 instead. Locally 1024 and 1025 are already bound so `jupyter_safe_port` returns 1026.

Let's say you have closed your laptop and lost all of your connections. If you can remember the remote port you used then `-c` will get you up and running in no time...
 
```
$ jupyter_safe_port example.lan -c 8081
Connect via:
ssh -N -f -L1024:localhost:8081 user@example.lan
```
