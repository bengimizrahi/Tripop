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

import pdb
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
            newBall = createBall(0, INITIAL_BALL_SPEED, type) 
            newBall.relCoordSystem = gameLayer.hexameshLayer
            #newBall.sprite.do(Repeat(RotateBy(360, 0.5)))
            self.gameLayer.addBall(newBall)

class HexameshLayer(Layer):

    is_event_handler = True

    def __init__(self):
        super(HexameshLayer, self).__init__()
        width, height = director.get_window_size()
        self.children_anchor = width/2, height/2

        self.hexamesh = Hexamesh(7, self)
        self.centerGrid = self.hexamesh.center
        self.centerGrid.setBall(Ball(0, 0, 0, BALL_TYPE_CORE))
        self.add(self.centerGrid.ball.sprite)
        self.attachedBalls = [self.centerGrid.ball]

    def addBall(self, ball):
        self.add(ball.sprite)
        self.attachedBalls.append(ball)

    def removeBall(self, ball):
        self.remove(ball.sprite)
        self.attachedBalls.remove(ball)

    def on_mouse_drag(self, x, y, dx, dy, buttons, modifiers):
        self.rotation = self.rotation + 180.0/GAME_AREA_RADIUS*dx

class GameLayer(Layer):

    def __init__(self):
        super(GameLayer, self).__init__()
        width, height = director.get_window_size()
        self.children_anchor = width/2, height/2

        self.freeBalls = []
        self.createBallLogic = CreateBallLogic(self)
        self.schedule(self.step)
        self.hexameshLayer = HexameshLayer()

    def step(self, dt):
        justAttachedBalls = []
        for aFreeBall in self.freeBalls:
            aFreeBall.move(dt)
            for anAttachedBall in self.hexameshLayer.attachedBalls:
                if aFreeBall.distance(anAttachedBall) <= 2*BALL_RADIUS:
                    anAttachedBall.connect(aFreeBall)
                    justAttachedBalls.append(aFreeBall)
                    self.removeBall(aFreeBall)
                    self.hexameshLayer.addBall(aFreeBall)
                    aFreeBall.relCoordSystem = None
                    break
        for ball in justAttachedBalls:
            if ball in self.freeBalls: self.freeBalls.remove(ball)

        self.createBallLogic(dt)

    def addBall(self, ball):
        self.add(ball.sprite)
        self.freeBalls.append(ball)

    def removeBall(self, ball):
        self.remove(ball.sprite)
        self.freeBalls.remove(ball)
	
if __name__ == "__main__":
    director.init(width=GAME_AREA_RADIUS*2, height=GAME_AREA_RADIUS*2, resizable=True)
    gameLayer = GameLayer()
    director.run(Scene(gameLayer, gameLayer.hexameshLayer))

