for x in 1337  6366 4444 2; do nmap -Pn --host-timeout 201 --max-retries 0 -p $x $TARGET && sleep 1; done
