# jupyter_safe_port

```
usage: jupyter_safe_port [-hcdf] {host} [port]

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
    -f    apply SSH argument to daemonize session (i.e. ssh -f)
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
ssh -N -L1024:localhost:1024 user@example.lan
```

You start the first notebook server. Now run `jupyter_safe_port` again...

```
$ jupyter_safe_port example.lan
Execute on example.lan:
jupyter notebook --no-browser --port=1025

Connect via:
ssh -N -L1025:localhost:1025 user@example.lan
```

The local port 1024 is already bound to the first server so it gives you 1025. On the remote system, `example.lan`, port 1024 is bound too so it returns 1025 as well. What if you want to use a higher port number on `example.lan`? Let's see...

```
$ jupyter_safe_port example.lan 8080
Execute on example.lan:
jupyter notebook --no-browser --port=8081

Connect via:
ssh -N -L1026:localhost:8081 user@example.lan
```

Oops, you forgot about that web server test. 8080 is already bound so you're given 8081 instead. Locally 1024 and 1025 are already bound so `jupyter_safe_port` returns 1026.

Let's say you have closed your laptop and lost all of your connections. If you can remember the remote port you used then `-c` will get you up and running in no time...
 
```
$ jupyter_safe_port example.lan -c 8081
Connect via:
ssh -N -L1024:localhost:8081 user@example.lan
```

## Scripting

You can use `jupyter_safe_port` in your scripts. `-d` returns the local port followed by the remote port.

```
$ jupyter_safe_port example.lan -d 8081
1024 8081
```

Here are a few ways to use it...

```shell
#!/usr/bin/env bash

# System to spawn the notebook server on
server=example.lan

# Conda environment to use
environ=XYZ

if ! [[ -x $(command -v "jupyter_safe_port") ]]; then
    echo "jupyter_safe_port is not installed" >&2
    exit 1
fi

result="$(jupyter_safe_port -d $server)"
if [ -z "$result" ]; then
    # jupyter_safe_port failed
    # case 1: not enough arguments
    # case 2: invalid argument
    # case 3: invalid port range
    # case 4: ssh failed to connect to $server
    exit 1
fi

# Extract ports from result
read port_local port_remote <<< "$result"
if [[ -z "$port_local" ]]; then
    # case 1: no local ports available
    exit 1
elif [[ -z "$port_remote" ]] || (( port_remote < 0 )); then
    # case 1: no remote ports available
    # case 2: if using '-c', no service is present on the requested port
    exit 1
fi

echo "Starting remote jupyter session on $server:$port_remote"
session="jupyter_${port_remote}"
ssh $server "tmux new-session -d -s $session \
    'source ~/.bash_profile \
    && source ~/local/miniconda3/etc/profile.d/conda.sh \
    && conda activate $environ \
    && jupyter notebook --no-browser --port=$port_remote'"
if (( $? )); then
    echo "Failed to connect to $server" >&2
    exit 1
fi

echo "Remote tmux session is: $session"
echo
echo "To kill the notebook server:"
echo "ssh $server 'tmux kill-session -t $session'"
echo

# Forward the ports to the local system
echo "Forwarding $server:$port_remote to localhost:$port_local"
echo "To interrupt the session press: ctrl-c"

ssh -N -L$port_local:localhost:$port_remote $server
if (( $? )); then
    echo "Failed to forward port." >&2
    exit 1
fi
```
