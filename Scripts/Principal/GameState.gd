extends Node

enum State {
	MENU,
	PLAYING,
	PAUSED,
	LOADING
}

var current_state = State.MENU
