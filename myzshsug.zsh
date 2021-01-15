_myzshsug_widget_wrapper_clear_postdisplay() {
	POSTDISPLAY=''
	if [ "$WIDGET" = "vi-backward-kill-word" ]; then
		zle .backward-kill-word
	elif [ "$WIDGET" = "vi-backward-delete-char" ]; then
		zle .backward-delete-char
	else
		zle .$WIDGET
	fi
}

_myzshsug_self_insert() {
	setopt localoptions noshwordsplit noksharrays
	zle .$WIDGET
	if [ -n "$RBUFFER" ]; then
		POSTDISPLAY=''
		return
	fi
	if [[ ${POSTDISPLAY[1]} == ${KEYS[-1]} ]]; then
		POSTDISPLAY=${POSTDISPLAY:1}
		# Same as what's typed, just move on
		((++CURSOR))
		# _myzshsug_set_highlight
	else
		_myzshsug_showsuggestion
	fi
}

_myzshsug_complete_word() {
	local PREVBUF="$BUFFER"
	setopt BASH_REMATCH
	zle complete-word
	if [[ "$PREVBUF$POSTDISPLAY" =~ ^$BUFFER(.*)$ ]]; then
		POSTDISPLAY="$BASH_REMATCH[2]"
		# _myzshsug_set_highlight
	else
		_myzshsug_showsuggestion
	fi
}

_myzshsug_showsuggestion() {
	local complete_word=$1
	if ! zle history-beginning-search-backward; then
		POSTDISPLAY=''
	else
		POSTDISPLAY=$RBUFFER
		RBUFFER=''
	fi
	# _myzshsug_set_highlight
}

# _myzshsug_set_highlight() {
# 	#if [ -n "$_MYZSHSUG_LAST_HIGHLIGHT" ]; then
# 	#	region_highlight=("${region_highlight[@]/$_MYZSHSUG_LAST_HIGHLIGHT}")
# 	#	unset _MYZSHSUG_LAST_HIGHLIGHT
# 	#fi
# 	_MYZSHSUG_LAST_HIGHLIGHT="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) fg=8"
# 	region_highlight=("$_MYZSHSUG_LAST_HIGHLIGHT")
# }

zle -N self-insert _myzshsug_self_insert
for wid in {vi-,}backward-delete-char \
	{vi-,}backward-kill-word \
	vi-{for,back}ward-{blank-,}word \
	vi-{for,back}ward-{blank-,}word-end \
	{vi-,}{for,back}ward-char; do
	zle -N $wid _myzshsug_widget_wrapper_clear_postdisplay
done
zle -N vi-add-eol _myzshsug_eol
zle -N vi-insert-bol _myzshsug_bol
zle -N _myzshsug_showsuggestion

zle -N _myzshsug_exec;
zle -N _myzshsug_accept_exec;
zle -N _myzshsug_complete_word;

_myzshsug_exec() {
	POSTDISPLAY=""
	zle accept-line
}
_myzshsug_bol() {
	POSTDISPLAY=''
	zle .$WIDGET
}
_myzshsug_eol() {
	BUFFER="$BUFFER$POSTDISPLAY"
	POSTDISPLAY=''
	zle .$WIDGET
}
_myzshsug_accept_exec() {
	BUFFER=$BUFFER$POSTDISPLAY
	POSTDISPLAY=""
	zle accept-line
}
bindkey '' _myzshsug_exec
bindkey '' _myzshsug_accept_exec
bindkey '' backward-delete-char
bindkey '	' _myzshsug_complete_word
