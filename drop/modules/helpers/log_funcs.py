# Bash functions to stream to log, tee to terminal and log, or stream to terminal
# for bash scripts or "shell" blocks. 
import drop
import wbuild
from pathlib import Path

projectDir = Path.cwd().resolve()
cfg = drop.config.DropConfig(wbuild.utils.Config(), projectDir)

# Get the stream argument to prevent redundant parameters. 
stream_info = f"""TO_LOG='{cfg.get("stream_to_log")}'"""

#https://stackoverflow.com/questions/16461656/how-to-pass-array-as-an-argument-to-a-function-in-bash#:~:text=You%20cannot%20pass%20an%20array%2C%20you%20can%20only%20pass%20its%20elements%20(i.e.%20the%20expanded%20array).
log_script = stream_info + """

    function logScript(){
        SCRIPT=$1
        ARGS=$2[@]
        ARGS=("${!ARGS}")
        LOG=$3

        if [[ "$TO_LOG" == "yes" ]]; then 
            $SCRIPT ${ARGS[@]} > $LOG 2>&1
        elif [[ "$TO_LOG" == "tee" ]]; then
            $SCRIPT ${ARGS[@]} 2>&1 | tee --append $LOG
        else
            $SCRIPT ${ARGS[@]}
        fi
    }

"""

log_code = stream_info + """

    function logCode(){
        CODE=$1[@]
        CODE=("${!CODE}")
        LOG=$2
        
        if [[ "$TO_LOG" == "yes" ]]; then 
            ${CODE[@]} > $LOG 2>&1
        elif [[ "$TO_LOG" == "tee" ]]; then 
            ${CODE[@]} 2>&1 | tee --append $LOG
        else
            ${CODE[@]}
    }

"""