from os import listdir
import math

DEBUG = not True
GAME_AREA_RADIUS = 160
BALL_RADIUS = 10
FOUR_RADIUS_SQR = 4 * (BALL_RADIUS**2)
LEVEL = 8
MOUSE_SENSITIVITY = 1
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

CENTER_POSITION = 0, 45

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

def convertCoord(position, fromLayer, toLayer):
    x, y = position
    angle = (-fromLayer.rotation + toLayer.rotation)/180.0*math.pi
    nx, ny = math.cos(angle)*x - math.sin(angle)*y, math.sin(angle)*x + math.cos(angle)*y
    return nx, ny

def closestGrid(grids):
    c = None
    for i in xrange(len(grids)):
        if grids[i] != None:
            c = grids[i]
            start = i+1
            break
    assert c != None
    for h in grids[start:]:
        if h != None:
            if h.distance < c.distance: c = h
            elif distcmp(h, c) == -1: c = h
    return c

def distcmp(a, b):
    x, y = a.position
    d1sqr = x**2 + y**2
    x, y = b.position
    d2sqr = x**2 + y**2
    return cmp(d1sqr, d2sqr)
