@icon('state.svg')
@abstract
class_name State
extends Node
## Parent class for all states and state machines.
## Has methods for all the normal Node input and update methods.

## The parent state machine. For all state-derived nodes, this will be [member Node.owner].
var state_machine : StateMachine

## Runs when the state is switched to, including when [member state_machine] is initalized.
## [param _msg] is a dictionary received from [method StateMachine.change_state], for passing variables between states.
@abstract
func on_start(_msg := {})

## Runs when the [member state_machine] switches to a different sibling state.
@abstract
func on_end()

## Treat this the same as [Node._input].
@abstract
func input(_event)

## Treat this the same as [Node._unhandled_input].
@abstract
func unhandled_input(_event)

## Treat this the same as [Node._process].
@abstract
func update(_delta)

## Treat this the same as [Node._physics_process].
@abstract
func physics_update(_delta)

## This is used for getting the visual name of this state, used for debug purposes. For State, it is [member Node.name]. [param _sep] is used by [StateMachine.get_state_tree_name].
func get_state_tree_name(_sep := '>'):
	return name
