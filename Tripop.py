from common import *
from Ball import *
from Hexagrid import *

import cocos
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
        self.ballSpeed = 70 #px/sec

    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallInterval = max(1, self.createBallInterval-0.1)
            self.createBallTimer = 0.0
            angle = 2*math.pi*random.random()
            type = random.choice(range(1,5))
            newBall = createBall(angle, self.ballSpeed, type) 
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
        self.add(ball.sprite, z=len(self.attachedBalls)+1)
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

        self.info = cocos.text.Label("Info", x=-150, y=-150);
        self.add(self.info);
        self.freeBalls = []
        self.createBallLogic = CreateBallLogic(self)
        self.schedule(self.step)
        self.hexameshLayer = HexameshLayer()

    def step(self, dt):
        def distance(attachedBall, freeBall):
            xf, yf = freeBall.position;
            xa, ya = attachedBall.positionOnLayer(self.hexameshLayer);
            d = math.sqrt((xf-xa)**2 + (yf-ya)**2)
            return d
            
        def angleBetween(pos1, pos2):
            x1, y1 = pos1
            x2, y2 = pos2
            r = math.atan2((y2-y1), (x2-x1))
            if r < 0: r += 2*math.pi
            return r

        def connect(attachedBall, freeBall):
            x1, y1 = attachedBall.position;
            x2, y2 = freeBall.positionOnLayer(self.hexameshLayer);
            angle = angleBetween((x1, y1), (x2, y2))
            x, y = x2-x1, y2-y1
            nb_idx = -1
            print "x, y = ", (x, y)
            print "angle = ", angle
            if x > 0 and y >= 0 and 0 <= angle < math.pi/3:
                nb_idx = 0
                x2 = 2*BALL_RADIUS*math.cos(math.pi/6)+x1
                y2 = 2*BALL_RADIUS*math.sin(math.pi/6)+y1
            elif y >= 0 and math.pi/3 <= angle < 2*math.pi/3:
                nb_idx = 1
                x2 = x1
                y2 = 2*BALL_RADIUS+y1
            elif x < 0 and y >= 0 and 2*math.pi/3 <= angle < math.pi:
                nb_idx = 2
                x2 = 2*BALL_RADIUS*math.cos(5*math.pi/6)+x1
                y2 = 2*BALL_RADIUS*math.sin(5*math.pi/6)+y1
            elif x < 0 and y < 0 and math.pi <= angle < 4*math.pi/3:
                nb_idx = 3
                x2 = 2*BALL_RADIUS*math.cos(7*math.pi/6)+x1
                y2 = 2*BALL_RADIUS*math.sin(7*math.pi/6)+y1
            elif y < 0 and 4*math.pi/3 <= angle < 5*math.pi/3:
                nb_idx = 4
                x2 = x1
                y2 = -2*BALL_RADIUS+y1
            elif y < 0 and 5*math.pi/3 <= angle < 2*math.pi:
                nb_idx = 5
                x2 = 2*BALL_RADIUS*math.cos(11*math.pi/6)+x1
                y2 = 2*BALL_RADIUS*math.sin(11*math.pi/6)+y1
            else:
                assert False, "connect error"
            self.info.element.text = "nb_idx = %s" % str(nb_idx)
            print "connected from ", nb_idx
            print "free ball's new position is ", (x2, y2)
            freeBall.position = x2, y2
            nb_hexagrid = attachedBall.hexagrid.neighbours[nb_idx]
            if nb_hexagrid == None:
                print "GAME OVER :))))"
                return
            nb_hexagrid.setBall(freeBall)
            freeBall.hexagrid = nb_hexagrid
            freeBall.velocity *= 0
            freeBall.sprite.stop()
            
        justAttachedBalls = []
        for aFreeBall in self.freeBalls:
            aFreeBall.move(dt)
            for anAttachedBall in self.hexameshLayer.attachedBalls:
                if distance(aFreeBall, anAttachedBall) <= 2*BALL_RADIUS:
                    connect(anAttachedBall, aFreeBall)
                    justAttachedBalls.append(aFreeBall)
                    self.removeBall(aFreeBall)
                    self.hexameshLayer.addBall(aFreeBall)
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

