#!/bin/bash

if [ -z "$SPC_DIR" ]; then
  SPC_DIR="${HOME}/.spc"
fi

SPC_REMOTE="${SPC_DIR}/remote"
SPC_REMOTES_DIR="${SPC_DIR}/remotes"

[ -d "$SPC_DIR" ] || mkdir "$SPC_DIR"
[ -d "$SPC_REMOTES_DIR" ] || mkdir "$SPC_REMOTES_DIR"


default_remote() {
  if [ -f "$SPC_REMOTE" ]; then
    cat "$SPC_REMOTE"
    return 0
  else
    return 1
  fi
}

print_remote() {
  cur_prefix="* "
  oth_prefix="  "
  if [ "$(default_remote || true)" == "$1" ]; then
    echo "${cur_prefix}$1"
  else
    echo "${oth_prefix}$1"
  fi
}

parse_config() {
  if [ ! -f "${SPC_REMOTES_DIR}/$1" ]; then
    echo "$1 not found"
  else
    address=$(awk -F "=" '/^address/{print $2}' "${SPC_REMOTES_DIR}/$1")
    params=$(awk -F "=" 'BEGIN{ORS=" "} !/^address/{print $1 " " $2}' "${SPC_REMOTES_DIR}/$1")
  fi
}

config_syntax_check() {
  ## syntax is valid if it contains only one "="

  local count
  count="$(echo "$1" | awk -F "=" '{print NF-1}')"
  if [[ ${count} -ne 1 ]]; then
    return 1
  fi
  return 0
}

command="$1"
case "$command" in
  remote )
    ## show the current remote

    if [ -n "$2" ]; then
      if [ ! -f "${SPC_REMOTES_DIR}/$2" ]; then
        echo "Remote not exists"
        exit
      else
        echo "$2"
        config="$2"
      fi
    else
      if ! default_remote; then
        echo "Remote not set"
        exit
      else
        config="$(default_remote)"
      fi
    fi

    echo "---------------"
    cat "${SPC_REMOTES_DIR}/${config}"
    echo

    ;;

  remotes )
    ## list all remotes

    for remote in "${SPC_REMOTES_DIR}"/*; do
      if [ -f "$remote" ]; then
        print_remote "${remote##*/}"
      fi
    done
    echo

    ;;

  default )
    ## set the default remote

    if [ -z "$2" ]; then
      echo "Usage: spc default name"
      exit
    fi
    remote_name=$2
    if [ -f "${SPC_REMOTES_DIR}/${remote_name}" ]; then
      echo "$remote_name" > "$SPC_REMOTE"
    else
      echo "${remote_name} not exists"
      exit
    fi
    ;;

  create )
    ## create the remote

    if [ -z "$2" ] || [ -z "$3" ]; then
      echo "Missing remote name or remote address"
      exit
    fi

    remote_name=$2
    remote_address=$3
    if [ -f "${SPC_REMOTES_DIR}/${remote_name}" ]; then
      echo "$remote_name already exists"
      exit
    else
      echo "address=${remote_address}" >> "${SPC_REMOTES_DIR}/${remote_name}"
    fi
    ;;

  delete )
    if [ -z "$2" ]; then
      echo "Missing remote name"
      exit
    fi

    if [ -f "${SPC_REMOTES_DIR}/$2" ]; then
      if [ "$(cat "${SPC_REMOTE}")" == "$2" ]; then
        rm "${SPC_REMOTE}"
      fi
      rm "${SPC_REMOTES_DIR}/$2"
    else
      echo "$2 not exist"
    fi

  ;;

  update )
    ## update remote config

    if [ -z "$2" ]; then
      echo "Missing remote name"
      exit
    elif [ ! -f "${SPC_REMOTES_DIR}/$2" ]; then
      echo "Remote not exist"
      exit
    fi

    filename="${SPC_REMOTES_DIR}/$2"
    shift 2

    if [ "$1" == "delete" ]; then
      shift
      if [ $# -eq 0 ]; then
        echo "Missing config"
        exit
      fi

      for config_key in "$@"; do
        ## In order to use `sed` on both linux and macos, generate backup file and delete it
        if grep -q "^${config_key}=.*" "${filename}" ; then
          sed -i.bak "/^${config_key}=.*/d" "${filename}"
          rm "${filename}.bak"
        else
          echo "${config_key} not found"
        fi
      done

    else

      if [ $# -eq 0 ]; then
        echo "Missing config"
        exit
      fi

      for config in "$@"; do
        if config_syntax_check "${config}"; then
          config_key=${config%=*}

          ## create or update config
          ## In order to use `sed` on both linux and macos, generate backup file and delete it
          if grep -q "^${config_key}=.*" "${filename}"; then
            sed -i.bak "s/^${config_key}=.*/${config}/g" "${filename}"
            rm "${filename}.bak"
          else
            echo "${config}" >> "${filename}"
          fi

        else
          echo "Config: ${config} is not valid."
          exit
        fi
      done
    fi
    ;;

  help | -h | --help | "" )
    # TODO: need fix

    echo "Usage: spc [<command>] [<args>]"
    echo "Commands:"
    printf "  %-8s %-22s  %s\n" ""        "Files"          "upload files to default remote machine"
    printf "  %-8s %-22s  %s\n" "add"     "Machine_name Address"   "add the remote to the remote machine list"
    printf "  %-8s %-22s  %s\n" "dn"      "[from Machine_name] Files"  "download files from default/specific remote machine"
    printf "  %-8s %-22s  %s\n" "help"    ""               "Display all commands"
    printf "  %-8s %-22s  %s\n" "modify"  "Machine_name [Configs]" "modify the remote machine config"
    printf "  %-8s %-22s  %s\n" "remote"  "[Machine_name]"       "show remote  machine config"
    printf "  %-8s %-22s  %s\n" "remotes" ""               "show remote machine list"
    printf "  %-8s %-22s  %s\n" "set"     "Machine_name"           "set the default remote machine"
    printf "  %-8s %-22s  %s\n" "to"      "Machine_name Files"     "upload files to specific remote machine"

    ;;

  dn )
    if [ -z "$2" ]; then
      echo "Missing filenames"
      exit
    fi

    if [ "$2" == "from" ]; then
      ## download from specific remote

      if [ -z "$3" ]; then
        echo "Missing remote"
        exit
      elif [ ! -f "${SPC_REMOTES_DIR}/$3" ]; then
        echo "Remote not exist"
        exit
      fi

      parse_config "$(cat "${SPC_REMOTE}")"
      shift 3

      echo "$*"
      if [ $# -gt 1 ]; then
        IFS=","
        scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "${address}:{$*}" "${HOME}/"
        IFS=" "
      else
        scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "${address}:$*" "${HOME}/"
      fi

    else
      ## download from default remote

      if [ ! -f "${SPC_REMOTE}" ]; then
        echo "Default remote not set"
        exit
      fi

      parse_config "$(cat "${SPC_REMOTE}")"
      shift

      if [ $# -gt 1 ]; then
        IFS=","
        scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "${address}:{$*}" "${HOME}/"
        IFS=" "
      else
        scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "${address}:$*" "${HOME}/"
      fi
    fi
    ;;

  to )
    ## upload to specific remote

    if [ -z "$2" ]; then
      echo "Missing remote"
      exit
    elif [ ! -f "${SPC_REMOTES_DIR}/$2" ]; then
      echo "Remote not exist"
      exit
    fi

    parse_config "$2"
    shift 2

    # have to remove leading and trailing space in $params
    scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "$@" "${address}:~/"

    ;;

  * )
    ## upload to default remote

    if [ ! -f "${SPC_REMOTE}" ]; then
      echo "Default remote not set"
      exit
    fi
    
    parse_config "$(cat "${SPC_REMOTE}")"

    # have to remove leading and trailing space in $params
    scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "$@" "${address}:~/"
    
    ;;
    
esac
