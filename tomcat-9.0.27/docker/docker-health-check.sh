 
#!/bin/bash

# Mauricio Melendez & Kevin Gómez | AMX GA/DT

. /tmp/.env

export LD_LIBRARY_PATH=/opt/rh/devtoolset-3/root/usr/lib64/

pgrep java

exit $?