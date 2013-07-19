from os import listdir

GAME_AREA_RADIUS = 160
BALL_RADIUS = 10
INITIAL_BALL_DISTANCE = 100
INITIAL_BALL_SPEED = 30

BALL_TYPE_CORE, BALL_TYPE_RED, BALL_TYPE_YELLOW, BALL_TYPE_GREEN, BALL_TYPE_BLUE = range(5)

IMAGES_DIR = 'Images/'

def imageForBallType(type):
    if type == BALL_TYPE_CORE:
	return IMAGES_DIR + 'Core.png'
    elif type == BALL_TYPE_RED:
	return IMAGES_DIR + 'SpiralRedWhiteBall.png'
    elif type == BALL_TYPE_YELLOW:
	return IMAGES_DIR + 'SpiralYellowWhiteBall.png'
    elif type == BALL_TYPE_GREEN:
	return IMAGES_DIR + 'SpiralGreenWhiteBall.png'
    elif type == BALL_TYPE_BLUE:
	return IMAGES_DIR + 'SpiralBlueWhiteBall.png'
    else:
	return IMAGES_DIR + 'Core.png'

