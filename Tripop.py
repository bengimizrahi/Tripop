from common import *
from Ball import *
from Hexagrid import *

from cocos.director import director
from cocos.layer import *
from cocos.scene import Scene
from cocos.actions.base_actions import *
from cocos.actions.interval_actions import *
from cocos.sprite import Sprite
from cocos.euclid import *
import pyglet
from pyglet.window import key

import math
import random

class CreateBallLogic:
    def __init__(self, gameLayer):
	self.gameLayer = gameLayer
	self.createBallInterval = 4.0
	self.createBallTimer = self.createBallInterval
	self.ballSpeed = 30 #px/sec
    def __call__(self, dt):
	self.createBallTimer += dt
	if (self.createBallTimer > self.createBallInterval):
	    self.createBallInterval = max(1, self.createBallInterval-0.1)
	    self.createBallTimer = 0.0
	    angle = 2*math.pi*random.random()
	    type = random.choice(range(1,5))
	    newBall = createBall(angle, INITIAL_BALL_SPEED, type) 
	    newBall.sprite.do(Repeat(RotateBy(360, 0.5)))
	    self.gameLayer.addBall(newBall)

class GameLayer(Layer):
    def __init__(self):
#view
	super(GameLayer, self).__init__()
	width, height = director.get_window_size()
	self.children_anchor = width/2, height/2
#model
	self.centerGrid = buildHexaMesh(7)
	self.centerGrid.setBall(Ball(0, 0, 0, BALL_TYPE_CORE))
	self.add(self.centerGrid.ball.sprite)
	self.attachedBalls = [self.centerGrid.ball]
	self.freeBalls = []
	self.createBallLogic = CreateBallLogic(self)
	self.schedule(self.step)
    def step(self, dt):
#start
	justAttachedBalls = []
	for aFreeBall in self.freeBalls:
	    aFreeBall.move(dt)
	    for anAttachedBall in self.attachedBalls:
		if aFreeBall.distance(anAttachedBall) <= 2*BALL_RADIUS:
		    anAttachedBall.connect(aFreeBall)
		    justAttachedBalls.append(aFreeBall)
		    self.attachedBalls.append(aFreeBall)
		    break
	for ball in justAttachedBalls:
	    self.freeBalls.remove(ball)
#logics
	self.createBallLogic(dt)
#end	
    def addBall(self, ball):
	self.add(ball.sprite)
	self.freeBalls.append(ball)

if __name__ == "__main__":
    director.init(width=GAME_AREA_RADIUS*2, height=GAME_AREA_RADIUS*2, resizable=True)
    director.run(Scene(GameLayer()))

