if [ -n "$ZSH_NAME" ]; then
  autoload -U +X compinit && compinit
  autoload -U +X bashcompinit && bashcompinit
  bashcompinit
fi

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

      if [[ " $commands " =~ " $command " ]]; then
        COMPREPLY=( $(compgen -W "$(spc "$command" --complete)" -- "$word") )
      elif [[ "$command" = "-r" ]]; then
        COMPREPLY=( $(compgen -W "$(spc upload --complete -r)" -- "$word") )
      else
        COMPREPLY=()
      fi

      ;;
    3)
      local command="${COMP_WORDS[1]}"
      local option="${COMP_WORDS[2]}"

      if [ "$command" = "upload" ] || [ "$command" = "download" ]; then
        COMPREPLY=( $(compgen -W "$(spc "$command" --complete "$option")" -- "$word") )
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
