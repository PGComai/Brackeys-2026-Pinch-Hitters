extends Enemy
class_name EnemyShieldGuy

func bubble():
	if state == State.STUNNED:
		super()
