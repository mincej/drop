# Bash functions to stream to log, tee to terminal and log, or stream to terminal
# for bash scripts or "shell" blocks. 
import drop
import wbuild
from pathlib import Path

projectDir = Path.cwd().resolve()
cfg = drop.config.DropConfig(wbuild.utils.Config(), projectDir)

# Get the stream argument to prevent redundant parameters. 
stream_info = f"""TO_LOG='{cfg.get("stream_to_log")}'"""

log_code = f"""
{stream_info}

function logCode(){{
    LOG=$1
    local FUNC=$2

    if [[ "$TO_LOG" == "yes" ]]; then 
        $FUNC > $LOG 2>&1
    elif [[ "$TO_LOG" == "tee" ]]; then 
        $FUNC 2>&1 | tee --append $LOG
    else
        $FUNC
    fi
}}

"""