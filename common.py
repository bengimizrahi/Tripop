from os import listdir
import math

#DEBUG = True
DEBUG = False
GAME_AREA_RADIUS = 160
BALL_RADIUS = 10
FOUR_RADIUS_SQR = 4 * (BALL_RADIUS**2)
INITIAL_BALL_DISTANCE = 100
INITIAL_BALL_SPEED = 40
LEVEL = 8
BALL_TYPE_CORE, BALL_TYPE_POPPING_BALL, BALL_TYPE_RED, BALL_TYPE_YELLOW, BALL_TYPE_GREEN, BALL_TYPE_BLUE = range(6)
RELPOS6 = [
    (2*BALL_RADIUS*math.cos(math.pi/6), 2*BALL_RADIUS*math.sin(math.pi/6)),
    (0, 2*BALL_RADIUS),
    (2*BALL_RADIUS*math.cos(5*math.pi/6), 2*BALL_RADIUS*math.sin(5*math.pi/6)),
    (2*BALL_RADIUS*math.cos(7*math.pi/6), 2*BALL_RADIUS*math.sin(7*math.pi/6)),
    (0, -2*BALL_RADIUS),
    (2*BALL_RADIUS*math.cos(11*math.pi/6), 2*BALL_RADIUS*math.sin(11*math.pi/6))
]
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

def IdGenerator():
    nextId = 0
    while(True):
        yield nextId
        nextId += 1

