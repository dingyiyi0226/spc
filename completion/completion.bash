#!/bin/bash

_spc(){

  COMPREPLY=()

  local commands="upload download create delete update remove remote remotes default help"
  local word="${COMP_WORDS[COMP_CWORD]}"

  case "$COMP_CWORD" in
    1)
      COMPREPLY=( $(compgen -W "$commands" -- "$word") )
      ;;
    2)
      local command="${COMP_WORDS[1]}"

      COMPREPLY=( $(compgen -W "$(bin/spc "$command" --complete)" -- "$word") )
      ;;
    3)
      local command="${COMP_WORDS[1]}"
      local option="${COMP_WORDS[2]}"

      if [ "$command" = "upload" ] || [ "$command" = "download" ]; then
        COMPREPLY=( $(compgen -W "$(bin/spc "$command" --complete "$option")" -- "$word") )
      else
        COMPREPLY=()
      fi
      ;;
    *)
      COMPREPLY=()
      ;;

  esac

}

complete -F _spc spc
