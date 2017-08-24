#!/usr/bin/env bash

SCM_GIT_CHAR="± "
SCM_HG_CHAR="☿ "
SCM_SVN_CHAR="⑆ "
SCM_NONE_CHAR=""
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX="${green}| "
SCM_GIT_BEHIND_CHAR="${red}↓${normal}"
SCM_GIT_AHEAD_CHAR="${bold_green}↑${normal}"
SCM_GIT_UNTRACKED_CHAR="⌀"
SCM_GIT_UNSTAGED_CHAR="${bold_yellow}•${normal}"
SCM_GIT_STAGED_CHAR="${bold_green}+${normal}"
GIT_THEME_PROMPT_DIRTY=" ${bold_red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${cyan}"
GIT_THEME_PROMPT_SUFFIX="${cyan}"
SCM_THEME_BRANCH_TRACK_PREFIX=' ⤏  '


RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="| "

VIRTUALENV_THEME_PROMPT_PREFIX="|"
VIRTUALENV_THEME_PROMPT_SUFFIX="| "

RBENV_THEME_PROMPT_PREFIX="|"
RBENV_THEME_PROMPT_SUFFIX="| "

RBFU_THEME_PROMPT_PREFIX="|"
RBFU_THEME_PROMPT_SUFFIX="| "

icon_branch=""

function git_prompt_info {
  git_prompt_vars
  echo -e " on $icon_branch $SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_GIT_AHEAD$SCM_GIT_BEHIND$SCM_GIT_STASH$SCM_SUFFIX"
}

function iterate_last_status_prompt {
    if [[ "$1" -ne 0 ]]; then
        LAST_STATUS_PROMPT="\n⚠ ${LAST_STATUS}"
    else
        LAST_STATUS_PROMPT=""
    fi
}

function prompt_command() {
    local LAST_STATUS="$?"
    iterate_last_status_prompt LAST_STATUS
    local new_PS1="${LAST_STATUS_PROMPT}\n ${bold_cyan}$(scm_char)${yellow}${green}\w${normal}$(scm_prompt_info)"

    local wrap_char=" "
    [[ ${#new_PS1} -gt $(($COLUMNS/1)) ]] && wrap_char="\n"
    PS1="${new_PS1}${green}${wrap_char}❯${reset_color} "
}

safe_append_prompt_command prompt_command
