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
        self.goingToPop = False
        
    def __repr__(self):
        dstr = ""
        if self.hexagrid and self.hexagrid.dirty: dstr = "/D"
        if self.hexagrid != None: return "<B:%d-H%d%s-T%d>" % (self.id, self.hexagrid.id, dstr, self.type)
        else: return "<B:%d----T%d>" % (self.id, self.type)

    @property
    def position(self):
        return self.sprite.position

    def positionOnLayer(self, layer):
        x, y = self.sprite.position
        angle = layer.rotation/180.0*math.pi
        nx, ny = math.cos(angle)*x - math.sin(angle)*y, math.sin(angle)*x + math.cos(angle)*y
        return nx, ny
        
    @position.setter
    def position(self, pos):
        self.sprite.position = pos
    
    def setPositionOnLayer(self, pos, layer):
        x, y = pos
        angle = layer.rotation
        nx, ny = math.cos(angle)*x - math.sin(angle)*y, math.sin(angle)*x + math.cos(angle)*y
        self.sprite.position = nx, ny
        
    def move(self, dt):
        x, y = self.position
        self.position = x+(self.velocity.x*dt), y+(self.velocity.y*dt)
