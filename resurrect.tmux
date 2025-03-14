#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/scripts/variables.sh"
source "$CURRENT_DIR/scripts/helpers.sh"

set_save_bindings() {
	local key_bindings=$(get_tmux_option "$save_option" "$default_save_key")
	local key
	for key in $key_bindings; do
		tmux bind-key "$key" run-shell "$CURRENT_DIR/scripts/save.sh"
	done
}

set_restore_bindings() {
	local key_bindings=$(get_tmux_option "$restore_option" "$default_restore_key")
	local key
	for key in $key_bindings; do
		tmux bind-key "$key" run-shell "$CURRENT_DIR/scripts/restore.sh"
	done
}


set_save_current_session_bindings() {
  tmux bind-key C-s run-shell "$CURRENT_DIR/scripts/save-current-session.sh"
}

set_restore_session_bindings() {
  tmux bind-key C-j display-popup -E "\
      /bin/cat $TMUX_HOME/resurrect/saved_sessions.tmux |\
      awk '{print \$2}' |\
      awk '!/^([0-9]|loca\/bin)/' |\
      uniq |\
      sort -u |\
      fzf --reverse --header jump-to-session |\
      xargs -I % tmux run-shell '$CURRENT_DIR/scripts/restore-session.sh %'"
}


set_default_strategies() {
	tmux set-option -gq "${restore_process_strategy_option}irb" "default_strategy"
	tmux set-option -gq "${restore_process_strategy_option}mosh-client" "default_strategy"
}

set_script_path_options() {
	tmux set-option -gq "$save_path_option" "$CURRENT_DIR/scripts/save.sh"
	tmux set-option -gq "$restore_path_option" "$CURRENT_DIR/scripts/restore.sh"
}

main() {
	set_save_bindings
  set_save_current_session_bindings
	set_restore_bindings
  set_restore_session_bindings
	set_default_strategies
	set_script_path_options
}
main
