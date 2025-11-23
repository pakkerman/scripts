fatal() {
  echo '[fatal]' "$@" >&2
  exit 1
}
