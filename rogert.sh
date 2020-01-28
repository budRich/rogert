#!/usr/bin/env bash

main() {
  local clip cls ins wid

  # global variables:
  _dunstid=5432
  _clipdir=/tmp/rogert
  _nextclip=0
  _lastclip=0
  _lines=6

  if [[ -n ${clip:=$(clipselect)} ]]; then

    mapfile -t window <<< "$(i3get --print dic)"
    cls=${window[2]} ins=${window[1]} wid=${window[0]}
    xdt=(xdotool key --clearmodifiers --window)

    xclip -sel c <<< "$clip"
    if [[ "$cls" = URxvt ]]; then
      sleep .1 && xclip -r <<< "$clip"
      "${xdt[@]}" "$wid" Shift+Insert
    elif [[ "$cls" = Sublime_text ]]; then
      subl --command 'paste_and_indent'
    else
      "${xdt[@]}" "$wid" ctrl+v
    fi
  fi

}

showclip() {
  # dont show more then lines
  dunstify --replace $_dunstid -t 0 "$(
   echo "${_clips[$_nextclip]}"
   echo "$((_nextclip+1))/${#_clips[@]}"
   head -${_lines:-5} "$_clipdir/${_clips[$_nextclip]}" 
  )"  
}

readclips() {

  declare -ga _clips
  # _clips[0]=""

  [[ -d $_clipdir ]] \
    && mapfile -t _clips <<< "$(ls -t "$_clipdir")"

  # clipdir is empty
  [[ ${_clips[*]} = "" ]] \
    && _clips[0]=$(xclip -sel c -o)

  _lastclip=$((${#_clips[@]}-1))
}

clipselect() {

  i3-msg -q mode rogert

  readclips
  showclip

  [[ ${_clips[*]} = "" ]] || while read -r ; do
    case "$REPLY" in

      v ) # next
        _nextclip=$((_nextclip<_lastclip?_nextclip+1:0))
        showclip 
      ;;

      c ) # prev
        _nextclip=$((_nextclip>0?_nextclip-1:_lastclip))
        showclip
      ;;

      x ) # select
        cat "$_clipdir/${_clips[$_nextclip]}"
        break
      ;;

      z|Escape ) # cancel
        break
      ;;

      b ) # delete
        rm "$_clipdir/${_clips[$_nextclip]}"
        readclips
        _nextclip=$((_nextclip>_lastclip?0:_nextclip))
        showclip
      ;;

    esac
  done < <(i3-msg  -t subscribe -m '["binding"]' \
            | stdbuf -o0 jq -r '.binding.symbol'
          )
}

finish() {
  i3-msg -q mode default
  dunstify --close $_dunstid
}

trap 'finish' EXIT

main "$@"
