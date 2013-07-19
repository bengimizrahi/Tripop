from common import *
from cocos.euclid import *
from cocos.sprite import Sprite
from cocos.text import Label

def createBall(approachingAngle, speed, type):
   x = GAME_AREA_RADIUS*math.cos(approachingAngle)
   y = GAME_AREA_RADIUS*math.sin(approachingAngle)
   newBall = Ball(x, y, speed, type)
   return newBall

class Ball(object):

    idGenerator = IdGenerator()

    def __init__(self, x, y, speed, type):
        self.id = self.idGenerator.next()
        self.sprite = Sprite(imageForBallType(type))
        self.sprite.position = x, y
        self.type = type
        self.velocity = Vector2(-x, -y).normalize()*speed
        self.hexagrid = None
        self.relCoordSystem = None
        #l = Label(str(self.id), (-5, -5))
        #self.sprite.add(l)
        
    def __repr__(self):
        return "<Ball-%d>" % (self.id)

    @property
    def position(self):
        if self.relCoordSystem:
            x, y = self.sprite.position
            angle = -1 * self.relCoordSystem.rotation
            nx, ny = math.cos(angle)*x - math.sin(angle)*y, math.sin(angle)*x + math.cos(angle)*y
            return nx, ny
        else:
            return self.sprite.position

    @position.setter
    def position(self, pos):
        if self.relCoordSystem:
            x, y = pos
            angle = self.relCoordSystem.rotation
            nx, ny = math.cos(angle)*x - math.sin(angle)*y, math.sin(angle)*x + math.cos(angle)*y
            self.sprite.position = nx, ny
        else:
            self.sprite.position = pos

    def distance(self, ball):
        x1, y1 = self.position
        x2, y2 = ball.position
        return math.sqrt((x1-x2)**2 + (y1-y2)**2)

    def angleTo(self, ball):
        x1, y1 = self.position
        x2, y2 = ball.position
        at = math.atan((y2-y1)/(x2-x1))
        if x2 >= x1 and y2 >= y1:
            return at
        elif x2 < x1 and y2 >= y1:
            return at + math.pi
        elif x2 < x1 and y2 < y1:
            return at + math.pi
        elif x2 >= x1 and y2 < y1:
            return at + 2*math.pi

    def move(self, dt):
        x, y = self.position
        self.position = x+(self.velocity.x*dt), y+(self.velocity.y*dt)

    def connect(self, ball):
        angle = self.angleTo(ball)
        x1, y1 = self.position
        x2, y2 = ball.position
        x = x2-x1
        y = y2-y1
        if x > 0 and y >= 0 and 0 <= angle < math.pi/3:
            nb_idx = 0
            x2 = 2*BALL_RADIUS*math.cos(math.pi/6)+self.sprite.x
            y2 = 2*BALL_RADIUS*math.sin(math.pi/6)+self.sprite.y
        elif y >= 0 and math.pi/3 <= angle < 2*math.pi/3:
            nb_idx = 1
            x2 = self.sprite.x
            y2 = 2*BALL_RADIUS+self.sprite.y
        elif x < 0 and y >= 0 and 2*math.pi/3 <= angle < math.pi:
            nb_idx = 2
            x2 = 2*BALL_RADIUS*math.cos(5*math.pi/6)+self.sprite.x
            y2 = 2*BALL_RADIUS*math.sin(5*math.pi/6)+self.sprite.y
        elif x < 0 and y < 0 and math.pi <= angle < 4*math.pi/3:
            nb_idx = 3
            x2 = 2*BALL_RADIUS*math.cos(7*math.pi/6)+self.sprite.x
            y2 = 2*BALL_RADIUS*math.sin(7*math.pi/6)+self.sprite.y
        elif y < 0 and 4*math.pi/3 <= angle < 5*math.pi/3:
            nb_idx = 4
            x2 = self.sprite.x
            y2 = -2*BALL_RADIUS+self.sprite.y
        elif y < 0 and 5*math.pi/3 <= angle < 2*math.pi:
            nb_idx = 5
            x2 = 2*BALL_RADIUS*math.cos(11*math.pi/6)+self.sprite.x
            y2 = 2*BALL_RADIUS*math.sin(11*math.pi/6)+self.sprite.y
        else:
            assert True, "connect error"
        ball.position = x2, y2
        nb_hexagrid = self.hexagrid.neighbours[nb_idx]
        if nb_hexagrid == None:
            print "GAME OVER :))))"
            return
        nb_hexagrid.ball = ball
        ball.hexagrid = nb_hexagrid
        ball.velocity *= 0
        ball.sprite.stop()
