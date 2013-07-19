from cocos.director import director
from cocos.layer import *
from cocos.scene import Scene
from cocos.actions.base_actions import *
from cocos.actions.interval_actions import *
from cocos.sprite import Sprite
from cocos.euclid import *

from os import listdir
import math
import random
import pyglet
from pyglet.window import key

GAME_AREA_RADIUS = 160
BALL_RADIUS = 10
CONNECTED_BALL = 0
ORBITTING_BALL = 1

images = listdir('Images')
ball_images = filter(lambda x: x.startswith('Spiral'), images)

class Ball():
    def __init__(self, x, y, speed, image=None):
	if not image:
	    image = 'Images/' + random.choice(ball_images)
	self.sprite = Sprite(image)
        self.sprite.position = x, y
        self.velocity = Vector2(-x, -y).normalize() * speed
	self.n = [None] * 6
    def position():
	x, y = self.sprite.position
	return (x*math.cos(angle) + y*math.sin(angle), -x*math.sin(angle) + y*math.cos(angle))
    def move(dt):
	x, y = self.sprite.position
	self.sprite.position = x + (self.velocity.x*dt), y + (self.velocity.y*dt)
    def dist(ball):
	x1, y1 = self.sprite.position
	x2, y2 = ball.sprite.position
	return math.sqrt((x1-x2)**2 + (y1-y2)**2)
    def angleTo(ball):
	x1, y1 = self.sprite.position
	x2, y2 = ball.sprite.position
	if x1 == x2:
	    return math.pi/2
	else:
	    return math.atan((y2-y1)/(x2-x1))
    def connectTo(ball):
	x1, y1 = self.sprite.position
	x2, y2 = ball.sprite.position
	x = x1-x2
	y = y1-y2
	angle = self.angleTo(ball)
	if x > 0 and y >= 0 and 0 <= angle < math.pi/3:
	    self.n[1] = ball
	    ball.n[4] = self
	    self.sprite.position = x2 + 2*BALL_RADIUS*math.cos(math.pi/6), y2 + 2*BALL_RADIUS*math.sin(math.pi/6)
	else if y >= 0 and math.pi/3 <= angle < 2*math.pi/3:
	    self.n[2] = ball
	    ball.n[5] = self
	    self.sprite.position = x2, y2 + 2*BALL_RADIUS
	else if x < 0 and y >= 0 and 2*math.pi/3 <= angle < math.pi:
	    self.n[3] = ball
	    ball.n[6] = self 
	    self.sprite.position = x2 + 2*BALL_RADIUS*math.cos(5*math.pi/6), y2 + 2*BALL_RADIUS*math.sin(5*math.pi/6)
	else if x < 0 and y < 0 and math.pi <= angle < 4*math.pi/3:
	    self.n[4] = ball
	    ball.n[1] = self
	    self.sprite.position = x2 + 2*BALL_RADIUS*math.cos(7*math.pi/6), y2 + 2*BALL_RADIUS*math.sin(7*math.pi/6)
	else if y < 0 and 4*math.pi/3 <= angle < 5*math.pi/3:
	    self.n[5] = ball
	    ball.n[2] = self
	    self.sprite.position = x2, y2 - 2*BALL_RADIUS
	else if y < 0 and 5*math.pi/3 <= angle < 2*math.pi:
	    self.n[6] = ball
	    ball.n[3] = self
	    self.sprite.position = x2 + 2*BALL_RADIUS*math.cos(11*math.pi/6), y2 + 2*BALL_RADIUS*math.sin(11*math.pi/6)
    def connectToAllNeighbours():
	neighbours = filter(lambda x: x[1] != None, enumerate(self.n));
	assert len(neighbours) > 0
	start, n_idx = neighbours[0]
	it = start.n[(n_idx+1)%6]
	while it:
	    self
	it = start.n[(n_idx-1)%6]
	while it:
	    pass

    def __repr__(self):
	return str(self.sprite.position) + str(self.velocity)

def createBall(approachingAngle, speed, image=None):
    x = GAME_AREA_RADIUS * math.cos(approachingAngle)
    y = GAME_AREA_RADIUS * math.sin(approachingAngle)
    return Ball(x, y, speed, image)

class GameLayer(Layer):
    def __init__(self):
        super(GameLayer, self).__init__()
        width, height = director.get_window_size()
        self.children_anchor = width/2, height/2
        self.initialBallDistance = 100
        self.orbitingBalls = []
	core = Ball(0, 0, 0, 'Images/Core.png')
	self.connectedBalls = [core]
	self.add(core.sprite)
	self.createBallLogic = CreateBallLogic(self)
	self.gametime = 0.0
        self.schedule(self.step)
    def addBall(self, ball):
	self.add(ball.sprite)
	self.orbitingBalls.append(ball)
    def removeBall(self, ball):
	self.remove(ball.sprite)
	self.orbitingBalls.remove(ball)
    def step(self, dt):
	self.gametime += dt
	markedBalls = []
        for ob in self.orbittingBalls:
	    ob.move(dt)
	    for cb in self.connectedBalls: 
		if ob.dist(cb) <= 2*BALL_RADIUS
		    cb.connect(ob)
		    markedBalls.append(ob) 
		    ob.connectToAllNeighbours()
		    #ob.pop()
	self.createBallLogic(dt)
	    
class CreateBallLogic:
    def __init__(self, gameLayer):
	self.gameLayer = gameLayer
	self.createBallInterval = 4.0
	self.createBallTimer = 4.0 
	self.ballSpeed = 30 #px/sec
    def __call__(self, dt):
	self.createBallTimer += dt
	if (self.createBallTimer > self.createBallInterval):
	    self.createBallInterval = max(1, self.createBallInterval - 0.1) 
	    self.createBallTimer = 0.0
	    newBall = createBall(random.random() * 2 * math.pi, self.ballSpeed)
	    newBall.sprite.do(Repeat(RotateBy(360, 0.5)))
	    self.gameLayer.addBall(newBall)

if __name__ == "__main__":
    director.init(width=GAME_AREA_RADIUS*2, height=GAME_AREA_RADIUS*2, resizable=True)
    director.run(Scene(GameLayer()))

