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

        self.hexamesh = Hexamesh(LEVEL, self)
        self.add(self.hexamesh.center.ball.sprite)
        self.attachedBalls = [self.hexamesh.center.ball]
        self.slidingBalls = []
        
    def addBall(self, ball):
        self.add(ball.sprite, z=len(self.attachedBalls)+1)
        self.attachedBalls.append(ball)

    def removeBall(self, ball):
        self.remove(ball.sprite)
        self.attachedBalls.remove(ball)

    def on_mouse_drag(self, x, y, dx, dy, buttons, modifiers):
        self.rotation = self.rotation + 180.0/GAME_AREA_RADIUS*dx

class GameLayer(Layer):

    def __init__(self, filename):
        super(GameLayer, self).__init__()
        width, height = director.get_window_size()
        self.children_anchor = width/2, height/2

        self.info = cocos.text.Label("Info", x=-150, y=-150);
        self.add(self.info);
        self.freeBalls = []
        self.createBallLogic = CreateBallLogic(self)
        self.schedule(self.step)
        self.hexameshLayer = HexameshLayer()
        if filename != None:
            self.fill(filename)

    def fill(self, filename):
        debug = True
        f = open(filename, 'r')
        if f != None:
            types = {'RED': BALL_TYPE_RED, 'YELLOW': BALL_TYPE_YELLOW, 'GREEN': BALL_TYPE_GREEN, 'BLUE': BALL_TYPE_BLUE}
            cursor = self.hexameshLayer.hexamesh.center
            for line in f.xreadlines():
                if line.startswith('#'): continue
                args = line.strip().split()
                if len(args) == 0: continue
                if args[0] == 'jump':
                    nb_idx = int(args[1])
                    cursor = cursor.neighbours[nb_idx]
                    if debug: print "jump to ", cursor
                elif args[0] == 'insert':
                    ball = Ball(0, 0, 0, types[args[1]])
                    cursor.setBall(ball)
                    if debug: print "after insertion ", cursor
                    self.hexameshLayer.addBall(ball)
                else:
                    print "invalid command: ", args[0]
        f.close()
    
    def distance(self, attachedBall, freeBall):
        xf, yf = freeBall.position;
        xa, ya = attachedBall.positionOnLayer(self.hexameshLayer);
        d = math.sqrt((xf-xa)**2 + (yf-ya)**2)
        return d

    def angleBetween(self, pos1, pos2):
        x1, y1 = pos1
        x2, y2 = pos2
        r = math.atan2((y2-y1), (x2-x1))
        if r < 0: r += 2*math.pi
        return r

    def connect(self, attachedBall, freeBall):
        x1, y1 = attachedBall.position;
        x2, y2 = freeBall.positionOnLayer(self.hexameshLayer);
        angle = self.angleBetween((x1, y1), (x2, y2))
        x, y = x2-x1, y2-y1
        if x > 0 and y >= 0 and 0 <= angle < math.pi/3: nb_idx = 0
        elif y >= 0 and math.pi/3 <= angle < 2*math.pi/3: nb_idx = 1
        elif x < 0 and y >= 0 and 2*math.pi/3 <= angle < math.pi: nb_idx = 2
        elif x < 0 and y < 0 and math.pi <= angle < 4*math.pi/3: nb_idx = 3
        elif y < 0 and 4*math.pi/3 <= angle < 5*math.pi/3: nb_idx = 4
        elif y < 0 and 5*math.pi/3 <= angle < 2*math.pi: nb_idx = 5
        else: assert False, "connect error"
        nb_hexagrid = attachedBall.hexagrid.neighbours[nb_idx]
        nb_hexagrid.setBall(freeBall)
        freeBall.velocity *= 0
        freeBall.sprite.stop()
        
    def pop(self, group):
        for h in group:
            self.hexameshLayer.removeBall(h.ball)
            h.setBall(None)
        arr = [self.hexameshLayer.hexamesh.center]
        group = [self.hexameshLayer.hexamesh.center]
        self.hexameshLayer.hexamesh.center.dirty = True
        while len(arr) > 0:
            h = arr.pop()
            for n in h.neighbours:
                if n != None and n.ball != None and n.dirty != True:
                    arr.append(n)
                    group.append(n)
                    n.dirty = True
        for h in group: h.dirty = False
        unconnected = list(set(self.hexameshLayer.attachedBalls) - set(group))
        self.hexameshLayer.slidingBalls.extend(unconnected)
        
    def step(self, dt):
        justAttachedBalls = []
        for aFreeBall in self.freeBalls:
            aFreeBall.move(dt)
            for anAttachedBall in self.hexameshLayer.attachedBalls:
                if self.distance(aFreeBall, anAttachedBall) <= 2*BALL_RADIUS:
                    if anAttachedBall.hexagrid.distance >= LEVEL:
                        print "GAME OVER!!!"
                        exit()
                    self.connect(anAttachedBall, aFreeBall)
                    justAttachedBalls.append(aFreeBall)
                    self.removeBall(aFreeBall)
                    self.hexameshLayer.addBall(aFreeBall)
                    group = aFreeBall.hexagrid.sameColorGroup()
                    if len(group) >= 3:
                        self.pop(group)
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
    filename = None
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    gameLayer = GameLayer(filename)
    director.run(Scene(gameLayer, gameLayer.hexameshLayer))

