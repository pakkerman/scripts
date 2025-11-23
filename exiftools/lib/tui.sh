#!/usr/bin/env bash

print-bottom-line() {
  local str="$1"

  printf '\e7'                  # save the cursor location
  printf '\e[%d;%dH' "$LINES" 0 # move cursor to the bottom line
  printf '\e[0K'                # clear the line
  printf '\e[3m\e[33m%s' "$str" # print the progress bar
  printf '\e8'                  # restore the cursor location

}

init-term() {
  printf '\n'                           # ensure we have space for the scrollbar
  printf '\e7'                          # save the cursor location
  printf '\e[%d;%dr' 0 "$((LINES - 1))" # set the scrollable region (margin)
  printf '\e8'                          # restore the cursor location
  printf '\e[1A'                        # move corsor up
}

deinit-term() {
  printf '\e7'                  # save the cursor location
  printf '\e[%d;%dr' 0 "$LINES" # reset the scrollable region (margin)
  printf '\e[%d;%dH' "$LINES" 0 # move cursor to the bottom line
  printf '\e[0K'                # clear the line
  printf '\e8'                  # reset the cursor location
}

tui-init() {
  shopt -s checkwinsize
  (:) # this lines to ensure LINES and COLUMNS are set, '()' to open subshell and ':' to do nothing

  trap deinit-term exit
  trap init-term winch
  init-term
}
