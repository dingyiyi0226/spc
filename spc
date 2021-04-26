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
    # declare config

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

    ;;

  remotes )
    ## list all remotes

    for remote in "${SPC_REMOTES_DIR}"/*; do
      if [ -f "$remote" ]; then
        print_remote "${remote##*/}"
      fi
    done
    ;;

  set )
    ## set the current remote

    if [ -z "$2" ]; then
      echo "Usage: spc set name"
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

  add )
    ## add the remote to the remote list

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

  modify )
    ## modify remote config in remote list

    if [ -z "$2" ]; then
      echo "Missing remote name"
      exit
    elif [ ! -f "${SPC_REMOTES_DIR}/$2" ]; then
      echo "Remote not exist"
      exit
    fi

    filename="${SPC_REMOTES_DIR}/$2"
    shift 2

    if [ $# -eq 0 ]; then
        echo "Missing config"
        exit
    fi

    for config in "$@"; do
      if config_syntax_check "${config}"; then
        config_key=${config%=*}

        ## sed command is different on MacOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
          grep -q "^${config_key}=.*" "${filename}" \
            && sed -i '' "s/^${config_key}=.*/${config}/g" "${filename}" \
            || echo "${config}" >> "${filename}"
        else
          grep -q "^${config_key}=.*" "${filename}" \
            && sed -i "s/^${config_key}=.*/${config}/g" "${filename}" \
            || echo "${config}" >> "${filename}"
        fi

      else
        echo "Config: ${config} is not valid."
        exit
      fi
    done
    ;;

  help | -h | --help | "" )
    echo "Usage: spc [<command>] [<args>]"
    echo "Commands:"
    printf "  %-8s %-15s  %s\n" "add"     "Name Address"   "add the remote to the remote list"
    printf "  %-8s %-15s  %s\n" "modify"  "Name [Configs]" "modify the remote config"
    printf "  %-8s %-15s  %s\n" "remote"  "[Remote]"       "show remote config"
    printf "  %-8s %-15s  %s\n" "remotes" ""               "show remote list"
    printf "  %-8s %-15s  %s\n" "set"     "Name"           "set the default remote"
    printf "  %-8s %-15s  %s\n" "to"      "Name [Files]"   "scp files to name"
    printf "  %-8s %-15s  %s\n" ""        "[Files]"        "scp files to default remote"

    ;;


  to )
    ## scp by choosing specific remote

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
    ## scp files to current remote

    if [ ! -f "${SPC_REMOTE}" ]; then
      echo "Default remote not set"
      exit
    fi
    
    parse_config "$(cat "${SPC_REMOTE}")"

    # have to remove leading and trailing space in $params
    scp -r "$(echo "${params}" | sed -E 's/^[[:blank:]]*|[[:blank:]]*$//g')" "$@" "${address}:~/"
    
    ;;
    
esac
