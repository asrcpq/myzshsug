myzshsug_delete() {
	POSTDISPLAY=''
	zle .$WIDGET
}

myzshsug_self_insert() {
	setopt localoptions noshwordsplit noksharrays
	LBUFFER="$LBUFFER$KEYS"
	if [ -n "$RBUFFER" ]; then
		POSTDISPLAY=''
		return
	fi
	if [[ ${POSTDISPLAY[1]} == ${KEYS[-1]} ]]; then
		POSTDISPLAY=${POSTDISPLAY:1}
		# Same as what's typed, just move on
		((++CURSOR))
		_myzshsug_set_highlight
	else
		show_suggestion
	fi
}

myzshsug_complete_word() {
	POSTDISPLAY=''
	zle complete-word
}

show_suggestion() {
	RBUFFER=''
	local complete_word=$1
	if ! zle history-beginning-search-backward; then
		POSTDISPLAY=''
	else
		POSTDISPLAY=$RBUFFER
		RBUFFER=''
		_myzshsug_set_highlight
	fi
}

_myzshsug_set_highlight() {
	region_highlight=("${(@)region_highlight:#$_MYZSHSUG_LAST_HIGHLIGHT}")
	_MYZSHSUG_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) fg=0"
	region_highlight+=("$_MYZSHSUG_LAST_HIGHLIGHT")
}

zle -N self-insert myzshsug_self_insert
zle -N backward-delete-char myzshsug_delete
zle -N vi-backward-delete-char myzshsug_delete
zle -N show-suggestion

zle -N myzshsug_exec;
zle -N myzshsug_accept_exec;
zle -N myzshsug_complete_word;
myzshsug_exec() {
	POSTDISPLAY=""
	zle accept-line
}
myzshsug_accept_exec() {
	BUFFER=$BUFFER$POSTDISPLAY
	POSTDISPLAY=""
	zle accept-line
}
bindkey '' myzshsug_exec
bindkey '' myzshsug_accept_exec
bindkey '	' myzshsug_complete_word
