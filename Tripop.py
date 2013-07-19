from common import *
from Ball import *
from Hexagrid import *

import cocos
from cocos.director import director
from cocos.layer import *
from cocos.scene import Scene
from cocos.actions.base_actions import *
from cocos.actions.interval_actions import *
from cocos.actions.instant_actions import *
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
        self.ballSpeed = 70#/0.001 #px/sec

    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallInterval = max(1, self.createBallInterval-0.1)
            self.createBallTimer = 0.0
            angle = 2*math.pi*random.random()
            type = random.choice([BALL_TYPE_RED, BALL_TYPE_GREEN, BALL_TYPE_YELLOW, BALL_TYPE_BLUE])
            newBall = createBall(angle, self.ballSpeed, type)
            self.gameLayer.addBall(newBall)

class HexameshLayer(Layer):

    is_event_handler = True

    def __init__(self):
        super(HexameshLayer, self).__init__()
        self.position = 0, 80
        self.children_anchor = 160, 240

        self.hexamesh = Hexamesh(LEVEL, self)
        self.add(self.hexamesh.center.ball.sprite)
        self.attachedBalls = [self.hexamesh.center.ball]
        self.poppingBalls = []
        self.lastReportedRotation = 0.0
        
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
        self.lastReportedRotation = self.rotation + 180.0/GAME_AREA_RADIUS*dx*MOUSE_SENSITIVITY
        
class GameLayer(Layer):

    def __init__(self, filename):
        super(GameLayer, self).__init__()
        self.image = pyglet.resource.image('Images/GameLayerImage.png')
        self.position = 0, 80
        self.children_anchor = 160, 240

        self.freeBalls = []
        self.createBallLogic = CreateBallLogic(self)
        self.schedule(self.step)
        self.hexameshLayer = HexameshLayer()
        self.infoLayer = InfoLayer()
        if filename != None:
            self.fill(filename)

    def draw(self):
        self.image.blit(0, 0)

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
        x1, y1 = attachedBall.position
        x2, y2 = freeBall.position
        angle = self.angleBetween((x1, y1), (x2, y2))
        x, y = x2-x1, y2-y1
        if x >= 0 and y >= 0 and 0 <= angle <= math.pi/3: nb_idx = 0
        elif y >= 0 and math.pi/3 <= angle <= 2*math.pi/3: nb_idx = 1
        elif x <= 0 and y >= 0 and 2*math.pi/3 <= angle <= math.pi: nb_idx = 2
        elif x <= 0 and y <= 0 and math.pi <= angle <= 4*math.pi/3: nb_idx = 3
        elif y <= 0 and 4*math.pi/3 <= angle <= 5*math.pi/3: nb_idx = 4
        elif y <= 0 and 5*math.pi/3 <= angle <= 2*math.pi: nb_idx = 5
        else: assert False, "connect error x=%.2f y=%.2f angle=%.2f" % (x, y, angle)
        nb_hexagrid = attachedBall.hexagrid.neighbours[nb_idx]
        assert nb_hexagrid.ball == None, "Can't connect, there is a ball %s in %s" % (nb_hexagrid.ball, nb_hexagrid)
        nb_hexagrid.setBall(freeBall)
        freeBall.velocity *= 0
    
    def addToPoppingBalls(self, balls):
        def avg(balls):
	    sum_x, sum_y = 0, 0
	    for b in balls:
		x, y = b.position
		sum_x += x 
		sum_y += y
	    avg_x, avg_y = sum_x/len(balls), sum_y/len(balls)
	    avg_x, avg_y = convertCoord((avg_x, avg_y), self.hexameshLayer, self.infoLayer)
            return avg_x, avg_y
        
	points = len(balls)*5
        self.infoLayer.addToScore(points)
        self.infoLayer.animatePoints(points, avg(balls))
        for b in balls: b.goingToPop = True
        self.hexameshLayer.poppingBalls.extend(balls)
        
    def updatePoppingBalls(self, dt):
        toBeRemoved = []
        for b in self.hexameshLayer.poppingBalls:
            b.sprite.scale -= dt*3
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
        while len(ballsToCheckForPopping) > 0:
            b = ballsToCheckForPopping.pop()
            if b.goingToPop == False:
                group = b.hexagrid.sameColorGroup()
                if len(group) >= 3:
                    self.addToPoppingBalls([h.ball for h in group])
                else:
                    ballsToCheckForPopping -= set([h.ball for h in group])

    def checkCollision(self, ball):
        def pdis(a, b, c):
            if DEBUG: print "begin pdis(a=", a, ", b=", b, ", c=", c
            t = a[0]-b[0], a[1]-b[1]
            if DEBUG: print "t = ", t
            dd = math.sqrt(t[0]**2+t[1]**2)
            if DEBUG: print "dd = ", dd
            assert dd > 0, "dd(%.2f) must be 0." % dd
            t = t[0]/dd, t[1]/dd
            if DEBUG: print "t = ", t
            n = -t[1], t[0]
            if DEBUG: print "n = ", n
            bc = c[0]-b[0], c[1]-b[1]
            if DEBUG: print "bc = ", bc
            vd = math.fabs(bc[0]*n[0]+bc[1]*n[1])
            hd = math.fabs(bc[0]*t[0]+bc[1]*t[1])
            ad = None
            if 2*BALL_RADIUS >= vd:
                ad = hd - math.sqrt(FOUR_RADIUS_SQR - vd**2)
            r = (dd, vd, hd, ad)
            if DEBUG: print r
            if DEBUG: print "end pdis()"
            return r
            
        pos = ball.positionOnLayer(self.hexameshLayer)
        prevPos = ball.prevPositionOnLayer(self.hexameshLayer)

        candidateBall = None
        for ab in self.hexameshLayer.attachedBalls:
            dd, ab.__verticalDist, ab.__horizontalDist, ab.__actualDist = pdis(pos, prevPos, ab.position)
            if DEBUG: print "dd, ab.__verticalDist, ab.__horizontalDist, ab.__actualDist = ", (dd, ab.__verticalDist, ab.__horizontalDist, ab.__actualDist)
            if ab.__actualDist != None:
                if DEBUG: print "ab.__actualDist(%s) != None" % ab.__actualDist
                if candidateBall == None or ab.__actualDist < candidateBall.__actualDist:
                    if candidateBall != None:
                        if DEBUG: print "candidateBall(%s) == None or ab.__actualDist(%.2f) < candidateBall.__actualDist(%.2f) is True." % (candidateBall, ab.__actualDist, candidateBall.__actualDist)
                    else:
                        if DEBUG: print "candidateBall(None) == None is True."
                    if dd > ab.__actualDist:
                        if DEBUG: print "dd(%.2f) > ab.__actualDist(%.2f) is True." % (dd, ab.__actualDist)
                        candidateBall = ab
                        if DEBUG: print "new candidate ball:", candidateBall
                    else:
                        if DEBUG: print "dd(%.2f) > ab.__actualDist(%.2f) is False." % (dd, ab.__actualDist)
                        if DEBUG: print "candidate ball is still:", candidateBall
                else:
                    if DEBUG: print "candidateBall(%s) == None or ab.__actualDist(%.2f) < candidateBall.__actualDist(%.2f) is False. Skipping ab(%s)" % (candidateBall, ab.__actualDist, candidateBall.__actualDist, ab)
            else:
                if DEBUG: print "ab.__actualDist is None"
            if DEBUG: print "--next-candidate--"
        if DEBUG: print "final candidateBall = ", candidateBall
        if DEBUG: print
        if candidateBall != None:
            x_a, y_a = pos
            x_b, y_b = prevPos
            assert candidateBall.__actualDist != None, "%s does not have __actualDist" % ab
            final_x = (candidateBall.__actualDist*(x_a-x_b) + dd*x_b) / dd
            final_y = (candidateBall.__actualDist*(y_a-y_b) + dd*y_b) / dd
            if DEBUG: print "final position becomes: ", (final_x, final_y)
            return candidateBall, (final_x, final_y)
        else:
            return None, None

    def step(self, dt):
        if dt == 0:
            if DEBUG: print "dt == 0, do nothing"
        self.hexameshLayer.prevRotation = self.hexameshLayer.rotation
        self.hexameshLayer.rotation = self.hexameshLayer.lastReportedRotation
        
        for freeBall in self.freeBalls:
            freeBall.moveByDeltaTime(dt)
            attachedBall, collidePosition = self.checkCollision(freeBall)
            if attachedBall != None:
                if attachedBall.hexagrid.distance >= LEVEL:
                    print "GAME OVER!!!"
                    exit()
                self.removeBall(freeBall)
                freeBall.position = collidePosition
                self.connect(attachedBall, freeBall)
                self.hexameshLayer.addBall(freeBall)
                group = freeBall.hexagrid.sameColorGroup()
                if len(group) >= 3:
                    self.addToPoppingBalls([h.ball for h in group])
            for ab in self.hexameshLayer.attachedBalls: ab.__verticalDist, ab.__horizontalDist = None, None
        self.updatePoppingBalls(dt)
        self.createBallLogic(dt)
        if DEBUG: print "-----------------------step-------------------------"
        if DEBUG: print "attachedBalls: ", self.hexameshLayer.attachedBalls

    def addBall(self, ball):
        self.add(ball.sprite)
        self.freeBalls.append(ball)

    def removeBall(self, ball):
        self.remove(ball.sprite)
        self.freeBalls.remove(ball)

class InfoLayer(Layer):

    def __init__(self):
        super(InfoLayer, self).__init__()
        self.position = 0, 80
        self.children_anchor = 160, 240

        self.score = 0
        self.hiscore = 0
        self.scoreLabel = cocos.text.Label("%06d" % self.score, x=-155, y=145)
        self.hiscoreLabel = cocos.text.Label("HI:%06d" % self.hiscore, x=80, y=145)
        self.add(self.scoreLabel)
        self.add(self.hiscoreLabel)

    def animatePoints(self, points, position):
        @CallFuncS
        def removeObj(object):
            self.remove(object)
	
        label = cocos.text.Label(str(points), x=position[0], y=position[1], anchor_x='center', anchor_y='center')
        label.visible = False
        self.add(label)
        action1 = Hide() + Delay(0.25) + Show()
        action2 = Delay(0.25) + ScaleBy(1.5, 0.5)
        action3 = Delay(0.75) + removeObj
        label.do(action1 | action2 | action3)

    def addToScore(self, points):
        self.score += points
        self.scoreLabel.element.text = "%06d" % self.score
        if self.score > self.hiscore:
            self.hiscore = self.score
            self.hiscoreLabel.element.text = "HI:%06d" % self.hiscore
        
        
if __name__ == "__main__":
    director.init(width=GAME_AREA_RADIUS*2, height=GAME_AREA_RADIUS*3, resizable=True)
    filename = None
    if len(sys.argv) > 1:
        filename = sys.argv[1]
    gameLayer = GameLayer(filename)
    director.run(Scene(gameLayer, gameLayer.hexameshLayer, gameLayer.infoLayer))
