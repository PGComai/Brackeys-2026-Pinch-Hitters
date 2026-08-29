extends Enemy
class_name EnemyShieldGuy

func bubble():
	if state == EnemyStateEnum.STUNNED:
		super()
