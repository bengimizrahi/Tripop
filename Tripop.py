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
        self.createBallInterval = 1.0
        self.createBallTimer = self.createBallInterval
        self.ballSpeed = 70 #px/sec

    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallInterval = max(1.0, self.createBallInterval-0.1)
            self.createBallTimer = 0.0
            angle = 2*math.pi*random.random()
            type = random.choice([BALL_TYPE_RED, BALL_TYPE_GREEN, BALL_TYPE_YELLOW, BALL_TYPE_BLUE])
            newBall = createBall(angle, self.ballSpeed, type)
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
        self.poppingBalls = []
        
    def addBall(self, ball):
        assert not ball in self.attachedBalls
        self.add(ball.sprite, z=len(self.attachedBalls)+1)
        self.attachedBalls.append(ball)

    def removeBall(self, ball):
        self.remove(ball.sprite)
        self.attachedBalls.remove(ball)

    def on_key_press(self, key, modifiers):
        global DEBUG
        if key == 100:
            DEBUG = not DEBUG 
        
    def on_mouse_motion(self, x, y, dx, dy):
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
        f = open(filename, 'r')
        if f != None:
            types = {'RED': BALL_TYPE_RED, 'YELLOW': BALL_TYPE_YELLOW, 'GREEN': BALL_TYPE_GREEN, 'BLUE': BALL_TYPE_BLUE}
            cursor = self.hexameshLayer.hexamesh.center
            nb_idx = -1
            for line in f.xreadlines():
                if line.startswith('#'): continue
                args = line.strip().split()
                if len(args) == 0: continue
                if args[0] == 'jump':
                    nb_idx = int(args[1])
                    cursor = cursor.neighbours[nb_idx]
                    if DEBUG: print "jump to ", cursor
                elif args[0] == 'insert':
                    opp = lambda x: (x+3)%6
                    assert nb_idx != -1
                    for t in args[1:]:
                        ball = Ball(0, 0, 0, types[t])
                        cursor.setBall(ball)
                        self.hexameshLayer.addBall(ball)
                        if DEBUG: print "after insertion ", cursor
                        cursor = cursor.neighbours[nb_idx]
                        if DEBUG: print "autojump to", cursor
                    cursor = cursor.neighbours[opp(nb_idx)]
                    if DEBUG: print "undo last autojump -> ", cursor
                else:
                    print "invalid command: ", args[0]
        f.close()
    
    def distanceSquared(self, attachedBall, freeBall):
        xf, yf = freeBall.position;
        xa, ya = attachedBall.positionOnLayer(self.hexameshLayer);
        d2 = (xf-xa)**2 + (yf-ya)**2
        return d2

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
        assert nb_hexagrid.ball == None, "Can't connect, there is a ball %s in %s" % (nb_hexagrid.ball, nb_hexagrid)
        nb_hexagrid.setBall(freeBall)
        freeBall.velocity *= 0
        freeBall.sprite.stop()
    
    def addToPoppingBalls(self, balls):
        for b in balls: b.goingToPop = True
        self.hexameshLayer.poppingBalls.extend(balls)
        
    def updatePoppingBalls(self, dt):
        toBeRemoved = []
        for b in self.hexameshLayer.poppingBalls:
            b.sprite.scale -= dt*4
            b.sprite.opacity -= dt*600
            if b.sprite.scale <= 0.01:
                toBeRemoved.append(b)
        if len(toBeRemoved) > 0:
            for b in toBeRemoved:
                self.hexameshLayer.poppingBalls.remove(b)
                self.hexameshLayer.removeBall(b)
                b.hexagrid.setBall(None)
            self.collapseUnconnectedBalls()

    def collapseUnconnectedBalls(self):
        arr = [self.hexameshLayer.hexamesh.center]
        connectedGrids = [self.hexameshLayer.hexamesh.center]
        self.hexameshLayer.hexamesh.center.dirty = True
        while len(arr) > 0:
            h = arr.pop()
            for n in h.neighbours:
                if n != None and n.ball != None and n.dirty != True:
                    arr.append(n)
                    connectedGrids.append(n)
                    n.dirty = True
        for h in connectedGrids: h.dirty = False
        connectedBalls = set([h.ball for h in connectedGrids])
        unconnectedBalls = list(set(self.hexameshLayer.attachedBalls)-set(connectedBalls))

        if len(unconnectedBalls) == 0:
            return
        if DEBUG: print "We are going to slide these: ", unconnectedBalls
        
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
        
        def slideBall(ball, h):
            assert h.ball == None, "Cannot slide ball, h.ball != None."
            oh = ball.hexagrid
            oh.setBall(None)
            h.setBall(ball)

        unconnectedBalls.sort(distcmp)
        ballsToCheckForPopping = set(unconnectedBalls[:])
        if DEBUG: print "We are going to apply sameColorGroup() to these: ", ballsToCheckForPopping
        
        while len(unconnectedBalls) > 0:
            b = unconnectedBalls.pop(0)
            if any([h != None and h.ball in connectedBalls for h in b.hexagrid.neighbours]):
                connectedBalls.add(b)
            else:
                h = closestGrid(b.hexagrid.neighbours)
                if h.ball == None:
                    slideBall(b, h)
                unconnectedBalls.append(b)
        
        poppingBallList = []
        print "ballsToCheckForPopping: ", ballsToCheckForPopping
        while len(ballsToCheckForPopping) > 0:
            b = ballsToCheckForPopping.pop()
            if b.goingToPop == False:
                group = b.hexagrid.sameColorGroup()
                print "sameColorGroup is ", group
                if len(group) >= 3:
                    self.addToPoppingBalls([h.ball for h in group])
                else:
                    ballsToCheckForPopping -= set([h.ball for h in group])

    def step(self, dt):
        self.pause()
        for aFreeBall in self.freeBalls:
            aFreeBall.move(dt)
            for anAttachedBall in self.hexameshLayer.attachedBalls:
                if self.distanceSquared(aFreeBall, anAttachedBall) <= FOUR_DIST_SQR:
                    if anAttachedBall.hexagrid.distance >= LEVEL:
                        print "GAME OVER!!!"
                        exit()
                    self.connect(anAttachedBall, aFreeBall)
                    self.removeBall(aFreeBall)
                    self.hexameshLayer.addBall(aFreeBall)
                    for b in self.hexameshLayer.attachedBalls:
                        assert b.hexagrid.dirty == False, "%s is dirty" % b
                    group = aFreeBall.hexagrid.sameColorGroup()
                    if len(group) >= 3:
                        self.addToPoppingBalls([h.ball for h in group])
                    break
        self.updatePoppingBalls(dt)
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

