myzshsug_delete() {
	RBUFFER=''
	zle .$WIDGET
}

myzshsug_self_insert() {
	setopt localoptions noshwordsplit noksharrays
	if [[ ${RBUFFER[1]} == ${KEYS[-1]} ]]; then
		# Same as what's typed, just move on
		((++CURSOR))
	else
		LBUFFER="$LBUFFER$KEYS"
		show_suggestion
	fi
}

myzshsug_complete_word() {
	RBUFFER=''
	zle complete-word
}

show_suggestion() {
	local complete_word=$1
	if ! zle .history-beginning-search-backward; then
		RBUFFER=''
		if [[ $LBUFFER[-1] != ' ' ]]; then
			integer curs=$CURSOR
			unsetopt automenu recexact
			CURSOR=$curs
		fi
	fi
}

zle -N self-insert myzshsug_self_insert
zle -N backward-delete-char myzshsug_delete
zle -N vi-backward-delete-char myzshsug_delete
zle -N show-suggestion

zle -N myzshsug_exec;
zle -N myzshsug_accept_exec;
zle -N myzshsug_complete_word;
myzshsug_exec() {
	RBUFFER=""
	zle accept-line
}
myzshsug_accept_exec() {
	zle accept-line
}
bindkey '' myzshsug_exec
bindkey '' myzshsug_accept_exec
bindkey '	' myzshsug_complete_word
