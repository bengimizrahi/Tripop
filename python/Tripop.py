from common import *
from Ball import *
from Hexagrid import *
from Logic import *

import cocos
from cocos import draw
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

import math

class HexameshLayer(Layer):

    is_event_handler = True

    def __init__(self):
        super(HexameshLayer, self).__init__()
        self.position = CENTER_POSITION
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
        
    def on_mouse_motion(self, x, y, dx, dy):
        self.lastReportedRotation = self.lastReportedRotation + 180.0/GAME_AREA_RADIUS*dx*MOUSE_SENSITIVITY

    def on_mouse_drag(self, x, y, dx, dy, buttons, modifiers):
        pass #self.lastReportedRotation = self.rotation + 180.0/GAME_AREA_RADIUS*dx*MOUSE_SENSITIVITY

class GameLayer(Layer):

    is_event_handler = True

    def __init__(self, filename):
        super(GameLayer, self).__init__()
        self.image = pyglet.resource.image('Images/GameLayerImage.png')
        self.position = CENTER_POSITION
        self.children_anchor = 160, 240

        self.freeBalls = []
        self.schedule(self.step)
        self.hexameshLayer = HexameshLayer()
        self.infoLayer = InfoLayer()
        if filename != None:
            self.fill(filename)
        
        self.prepareLevels()
        
    def prepareLevels(self):
    
        arr = [BALL_TYPE_RED, BALL_TYPE_GREEN, BALL_TYPE_YELLOW, BALL_TYPE_BLUE]
        random.shuffle(arr)
        
        warmups = [
            Logic_CreateBall_Simple(self, types=arr[:2], repeat=30, ballSpeed=70, createBallInterval=1.0), # 30 secs
            Logic_CreateBall_Simple(self, types=arr[:3], repeat=30, ballSpeed=70, createBallInterval=1.0), # 30 secs
            Logic_CreateBall_Simple(self, types=arr, repeat=60, ballSpeed=70, createBallInterval=1.0),    # 1 mins
            Logic_CreateBall_Distinct(self, types=arr, repeat=60, ballSpeed=70, createBallInterval=1.0),    # 1 mins

        ]
        simults = [
            Logic_CreateBall_Simultaneous(self, types=arr, repeat=30, ballSpeed=70, createBallInterval=2.0, simul=2), # 1 min
            Logic_CreateBall_Simultaneous(self, types=arr, repeat=20, ballSpeed=70, createBallInterval=3.0, simul=3), # 1 min
            Logic_CreateBall_Simultaneous(self, types=arr, repeat=30, ballSpeed=70, createBallInterval=2.0, simul=3), # 1 min
            Logic_CreateBall_Simultaneous(self, types=arr, repeat=15, ballSpeed=70, createBallInterval=4.0, simul=4), # 1 min
            Logic_CreateBall_Simultaneous(self, types=arr, repeat=20, ballSpeed=70, createBallInterval=3.0, simul=4), # 1 min
            Logic_CreateBall_Simultaneous(self, types=arr, repeat=30, ballSpeed=70, createBallInterval=2.0, simul=4), # 1 min
        ]
        sinusesAdded = [
            Logic_CreateBall_Distinct(self, types=arr, repeat=30, ballSpeed=70, createBallInterval=1.0),    # 30 secs
            Logic_Parallel_Execution(self, [ # 3 min
                Logic_CreateBall_Distinct(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=1.0),
                Logic_CreateBall_Simple_Sinus(self, types=arr, repeat=45, ballSpeed=20, createBallInterval=4.0, angularSpeed=math.pi/2),
            ]),
            Logic_Parallel_Execution(self, [ # 3 min
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=90, ballSpeed=70, createBallInterval=2.0, simul=2),
                Logic_CreateBall_Simple_Sinus(self, types=arr, repeat=45, ballSpeed=20, createBallInterval=4.0, angularSpeed=math.pi/2),
            ]),
            Logic_Parallel_Execution(self, [ # 3 min
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=1.0, simul=2),
                Logic_CreateBall_Simple_Sinus(self, types=arr, repeat=45, ballSpeed=20, createBallInterval=4.0, angularSpeed=math.pi/2),
            ]),
            Logic_Parallel_Execution(self, [ # 3 min
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=90, ballSpeed=70, createBallInterval=2.0, simul=3),
                Logic_CreateBall_Simple_Sinus(self, types=arr, repeat=45, ballSpeed=20, createBallInterval=4.0, angularSpeed=math.pi/2),
            ]),
            Logic_Parallel_Execution(self, [ # 3 min
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=2.0, simul=4),
                Logic_CreateBall_Simple_Sinus(self, types=arr, repeat=45, ballSpeed=20, createBallInterval=4.0, angularSpeed=math.pi/3),
                Logic_CreateBall_Simple_Sinus(self, types=arr, repeat=30, ballSpeed=20, createBallInterval=6.0, angularSpeed=math.pi/2),
            ]),
        ]
        test = [
            Logic_Parallel_Execution(self, [
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=2.0, simul=2),
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=2.0, simul=3),
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=2.0, simul=4),
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=2.0, simul=4),
                Logic_CreateBall_Simultaneous(self, types=arr, repeat=180, ballSpeed=70, createBallInterval=2.0, simul=4),
            ])
        ]
                
        
        self.logics_createBall = []
        #self.logics_createBall.extend(test)
        self.logics_createBall.extend(warmups)
        self.logics_createBall.extend(simults)
        self.logics_createBall.extend(sinusesAdded)

        self.createBallLogic = self.logics_createBall.pop(0)

    def draw(self):
        self.image.blit(0, 0)

    def avg(self, objects):
        sum_x, sum_y = 0, 0
        for obj in objects:
            x, y = obj.position
            sum_x += x 
            sum_y += y
            avg_x, avg_y = sum_x/len(objects), sum_y/len(objects)
            avg_x, avg_y = convertCoord((avg_x, avg_y), self.hexameshLayer, self.infoLayer)
            return avg_x, avg_y

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
                        ball = Ball(types[t])
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
        #assert nb_hexagrid.ball == None, "Can't connect, there is a ball %s in %s" % (nb_hexagrid.ball, nb_hexagrid)
        if nb_hexagrid.ball != None:
            freeBall.moveByDeltaTime(-1)
            return False
        nb_hexagrid.setBall(freeBall)
        freeBall.moveStrategy = None
        return True
    
    def addToPoppingBalls(self, balls):
        points = 5*len(balls)
        self.infoLayer.addToScore(points)
        self.infoLayer.power += max(0, len(balls)-2)
        self.infoLayer.power = min(self.infoLayer.power, 16)
        self.infoLayer.powerLabel.element.text = "Power:%d" % self.infoLayer.power
        self.infoLayer.animatePoints(str(points), self.avg(balls), 0.25, 0.5)
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
                
        def slideBall(ball, h):
            assert h.ball == None, "Cannot slide ball, h.ball != None."
            oh = ball.hexagrid
            oh.setBall(None)
            h.setBall(ball)
        
        slidingBalls = unconnectedBalls[:]
        ballsToCheckForPopping = set(unconnectedBalls[:])
        slidingBalls.sort(distcmp)
        
        while len(slidingBalls) > 0:
            b = slidingBalls.pop(0)
            if any([h != None and h.ball in connectedBalls for h in b.hexagrid.neighbours]):
                connectedBalls.add(b)
            else:
                h = closestGrid(b.hexagrid.neighbours)
                if h.ball == None:
                    slideBall(b, h)
                slidingBalls.append(b)
        
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
                        if DEBUG: print "ab.__actualDist(%.2f) < candidateBall.__actualDist(%.2f) is True." % (candidateBall, ab.__actualDist, candidateBall.__actualDist)
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
            return
        self.hexameshLayer.prevRotation = self.hexameshLayer.rotation
        self.hexameshLayer.rotation = self.hexameshLayer.lastReportedRotation
        
        for freeBall in self.freeBalls:
            freeBall.moveByDeltaTime(dt)
            attachedBall, collidePosition = self.checkCollision(freeBall)
            if attachedBall != None:
                if attachedBall.hexagrid.distance >= LEVEL:
                    print "GAME OVER!!! Score: ", self.infoLayer.score
                    exit()
                self.removeBall(freeBall)
                freeBall.position = collidePosition
                if self.connect(attachedBall, freeBall):
                    self.hexameshLayer.addBall(freeBall)
                    group = freeBall.hexagrid.sameColorGroup()
                    if len(group) >= 3:
                        self.addToPoppingBalls([h.ball for h in group])
            for ab in self.hexameshLayer.attachedBalls: ab.__verticalDist, ab.__horizontalDist = None, None
        self.updatePoppingBalls(dt)
        self.createBallLogic(dt)
        if self.createBallLogic.isExpired():
            self.createBallLogic = self.logics_createBall.pop(0)
        if DEBUG: print "-----------------------step-------------------------"
        if DEBUG: print "attachedBalls: ", self.hexameshLayer.attachedBalls

    def addBall(self, ball):
        self.add(ball.sprite)
        self.freeBalls.append(ball)

    def removeBall(self, ball):
        self.remove(ball.sprite)
        self.freeBalls.remove(ball)

    def on_key_press(self, key, modifiers):
        global DEBUG
        print key
        if key == 32:
            if self.infoLayer.power > 8:
                balls = [h.ball for h in self.hexameshLayer.hexamesh.rings[0] if h.ball != None and h.ball.goingToPop == False]
                self.infoLayer.power = 0
                self.infoLayer.powerLabel.element.text = "Power: 0"
                if len(balls) > 0:
                    self.addToPoppingBalls(balls)
        elif key == 100:
            DEBUG = not DEBUG 

class InfoLayer(Layer):

    def __init__(self):
        super(InfoLayer, self).__init__()
        self.position = CENTER_POSITION
        self.children_anchor = 160, 240

        self.score = 0
        self.hiscore = 0
        self.power = 0
        self.scoreLabel = cocos.text.Label("%06d" % self.score, x=-155, y=145)
        self.hiscoreLabel = cocos.text.Label("HI:%06d" % self.hiscore, x=80, y=145)
        self.powerLabel = cocos.text.Label("Power:%d" % self.power, x=-155, y=-165)
        self.add(self.scoreLabel)
        self.add(self.hiscoreLabel)
        self.add(self.powerLabel)

    def animatePoints(self, points, position, delay, duration):
        @CallFuncS
        def removeObj(object):
            self.remove(object)
	
        label = cocos.text.Label(points, x=position[0], y=position[1], anchor_x='center', anchor_y='center')
        label.visible = False
        self.add(label)
        action1 = Hide() + Delay(delay+0.01) + Show()
        action2 = Delay(delay+0.01) + ScaleBy(1.5, duration)
        action3 = Delay(delay+0.01+duration) + removeObj
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
