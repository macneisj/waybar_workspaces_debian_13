#!/usr/bin/env bash
# Must be in input group
#~/.local/bin/Hide_Cursor.sh

exec 6< <(
    stdbuf -oL libinput debug-events
)

triggered=0

while true; do
    if IFS= read -r -t 3 -u 6 line; then
        # Parse the first two fields
        read -r device event _ <<< "$line"

        if [[ "$device" == "event5" && "$event" == "POINTER_MOTION" ]]; then
            # Motion resumed, so allow a future trigger
            triggered=0
        fi
    else
        status=$?

        # Bash returns 142 when read times out
        if [[ $status -eq 142 && $triggered -eq 0 ]]; then
            wtype -M win -M Shift -P h -s 500 -m win -m Shift -p h
            triggered=1
        elif [[ $status -ne 142 ]]; then
            # EOF or another read error
            break
        fi
    fi
done
