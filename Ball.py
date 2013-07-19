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
        self.normalizedVelocity = Vector2(-x, -y).normalize()
        self.velocity = self.normalizedVelocity*speed
        self.hexagrid = None
        self.goingToPop = False
        self.__verticalDist = None
        self.__horizontalDist = None
        self.__actualDist = None

    def __repr__(self):
        dstr = ""
        if self.hexagrid and self.hexagrid.dirty: dstr = "/D"
        x, y = self.position
        if self.hexagrid != None: return "<B%d:(~%d,~%d)-H%d%s-T%d>" % (self.id, int(x), int(y), self.hexagrid.id, dstr, self.type)
        else: return "<B%d:(~%d,~%d)----T%d>" % (self.id, int(x), int(y), self.type)

    @property
    def position(self):
        return self.sprite.position

    @property
    def prevPosition(self):
        return self.sprite.prevPosition
    
    def positionOnLayer(self, layer):
        x, y = self.sprite.position
        angle = layer.rotation/180.0*math.pi
        nx, ny = math.cos(angle)*x - math.sin(angle)*y, math.sin(angle)*x + math.cos(angle)*y
        return nx, ny
    
    def prevPositionOnLayer(self, layer):
        px, py = self.sprite.prevPosition
        angle = layer.prevRotation/180.0*math.pi
        npx, npy = math.cos(angle)*px - math.sin(angle)*py, math.sin(angle)*px + math.cos(angle)*py
        return npx, npy

    @position.setter
    def position(self, pos):
        self.sprite.prevPosition = self.sprite.position
        self.sprite.position = pos
    
    def moveByDeltaTime(self, dt):
        x, y = self.position
        self.position = x+(self.velocity.x*dt), y+(self.velocity.y*dt)

    def moveByDeltaDist(self, dd):
        x, y = self.position
        self.position = x+(self.normalizedVelocity.x*dd), y+(self.normalizedVelocity.y*dd)
