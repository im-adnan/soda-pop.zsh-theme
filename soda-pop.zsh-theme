# Colors - Optimized for Light & Dark Modes
RESET="%f%b"
USER_COLOR="%F{197}"                 # Vibrant Magenta/Pink (Highly visible on both)
HOST_COLOR="%F{2}"                   # Standard Green (Consistent contrast)
DIR_COLOR="%F{33}"                   # Mid-tone Cerulean Blue (Readable on black & white)
GIT_INFO_COLOR="%F{208}"             # Cyan (Sharp and crisp everywhere)
BRACKET_COLOR="%B%F{242}"            # Medium Gray Brackets (Avoids pitch black or pure white)
ASTERISK_COLOR="%F{99}"              # Deep Coral Orange
TIME_COLOR="%F{136}"                 # Darker Gold/Yellow (Won't wash out on light backgrounds)
COST_COLOR="%F{71}"                  # Mild Sage Green (Calm, readable execution cost)
CMD_STATUS_COLOR="%F{196}"           # Clear Error Red
RETURN_ARROW_COLOR="%F{6}"           # Slate Purple/Blue
LAMBDA_COLOR="%F{28}"                # Forest/Emerald Green

# Load zsh modules for fast, pure-shell execution (No gdate or bc required!)
zmodload zsh/datetime

preexec() {
    _ADNAN_COMMAND_TIME_BEGIN=$EPOCHREALTIME
}

precmd() {
    local last_cmd_return_code=$?

    output_command_execute_after() {
        if [[ -z "$_ADNAN_COMMAND_TIME_BEGIN" ]]; then
            export ADNAN_RPROMPT_TEXT=""
            return 1
        fi

        local command_result=$1

        # time
        local time="$(date +%H:%M:%S)"

        # cost
        local time_end=$EPOCHREALTIME
        local cost_val
        (( cost_val = time_end - _ADNAN_COMMAND_TIME_BEGIN ))
        unset _ADNAN_COMMAND_TIME_BEGIN
        
        local cost=""
        if (( cost_val > 0 )); then
            cost="cost $(printf "%.3f" $cost_val)s"
        else
            cost="cost N/As"
        fi

        local cmd_status_color=""
        if $command_result; then
            cmd_status_color="${COST_COLOR}" # success green
        else
            cmd_status_color="${CMD_STATUS_COLOR}" # fail red
        fi

        export ADNAN_RPROMPT_TEXT="${BRACKET_COLOR}[${RESET}${TIME_COLOR}${time}${RESET}${BRACKET_COLOR}] [${RESET}${cmd_status_color}${cost}${RESET}${BRACKET_COLOR}]${RESET}"
    }

    local last_cmd_result=true
    if [ "$last_cmd_return_code" = "0" ]; then
        last_cmd_result=true
    else
        last_cmd_result=false
    fi

    output_command_execute_after $last_cmd_result
}

setopt PROMPT_SUBST

# git status config to match bracket style
ADNAN_THEME_GIT_PROMPT_PREFIX="${BRACKET_COLOR}[${RESET}"
ADNAN_THEME_GIT_PROMPT_SUFFIX="${BRACKET_COLOR}]${RESET}"
ADNAN_THEME_GIT_PROMPT_SEPARATOR="|"
ADNAN_THEME_GIT_PROMPT_BRANCH="${GIT_INFO_COLOR}"

# Source the fast asynchronous git prompt from the same directory
source ${0:A:h}/soda-git-prompt.zsh

_adnan_python_info() {
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        echo "${BRACKET_COLOR}[%F{135}${CONDA_DEFAULT_ENV}${BRACKET_COLOR}]${ASTERISK_COLOR}⁕"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        local parent=${VIRTUAL_ENV:h}
        if [[ "${PWD/#$parent/}" != "$PWD" ]]; then
            echo "${BRACKET_COLOR}[%F{135}${VIRTUAL_ENV:t}${BRACKET_COLOR}]${ASTERISK_COLOR}⁕"
        else
            echo "${BRACKET_COLOR}[%F{135}${VIRTUAL_ENV/#$HOME/~}${BRACKET_COLOR}]${ASTERISK_COLOR}⁕"
        fi
    fi
}

# Define the prompt layout
PROMPT='${LAMBDA_COLOR}λ${BRACKET_COLOR}[${USER_COLOR}%n${BRACKET_COLOR}@${HOST_COLOR}%m${BRACKET_COLOR}]${ASTERISK_COLOR}⁕$(_adnan_python_info)${BRACKET_COLOR}[${DIR_COLOR}%~${BRACKET_COLOR}]$(gitprompt)${RETURN_ARROW_COLOR}↲${RESET} '
RPROMPT='${ADNAN_RPROMPT_TEXT}'
