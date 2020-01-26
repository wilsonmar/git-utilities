#!/usr/bin/env bash
# based on https://gist.github.com/nilsding/b6105a8949955ce81f82dabc37650640

# Print a message
#
# Params:
#   $1: colour (red | green | yellow)
#   $*: status to print
#
# Example usage:
#   print_msg green "Successfully built $something"
#
#   print_msg red "An error occurred:" $msg
print_msg() {
  color="1"
  case $1 in
    red)    color="31;1" ;;
    green)  color="32;1" ;;
    yellow) color="33;1" ;;
  esac
  shift
  # shellcheck disable=SC1117
  printf " \033[${color}m*\033[0;1m %s\033[0m\n" "$*"
}

# Require an application to be in $PATH.
#
# Params:
#   $1: app name
#
# Example usage:
#   require_app ruby
require_app() {
  if ! command -v "$1" > /dev/null; then
    print_msg red "$1 not found, please install it"
    return 1
  fi
}

###############################################################################

require_app shellcheck || exit 0

changed_shell_files=$(
  git diff --cached --name-only --diff-filter=ACM |
  xargs grep -lE '^#!/.*(sh|bash|ksh)'
)

print_msg yellow "Running shellcheck..."
# shellcheck disable=SC2086
if shellcheck -a $changed_shell_files; then
  print_msg green "shellcheck approved your shell scripts, nice"
else
  print_msg red "shellcheck disapproves of your changes (return code: $?), "\
                "fix the errors and come back later"
  exit 1
fi
