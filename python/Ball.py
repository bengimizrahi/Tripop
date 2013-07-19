from common import *
from cocos.euclid import *
from cocos.sprite import Sprite
from cocos.text import Label

class MoveStrategy(object):
    
    def __init__(self, ball):
        assert ball.sprite != None, "ball does not have a sprite"
        self.ball = ball

class LineerMoveStrategy(MoveStrategy):
    
    def __init__(self, approachingAngle, speed, ball):
        super(LineerMoveStrategy, self).__init__(ball)
        x = GAME_AREA_RADIUS*math.cos(approachingAngle)
        y = GAME_AREA_RADIUS*math.sin(approachingAngle)
        self.ball.sprite.position = x, y
        self.normalizedVelocity = Vector2(-x, -y).normalized()
        self.velocity = self.normalizedVelocity*speed
            
    def moveByDeltaTime(self, dt):
        x, y = self.ball.position
        self.ball.position = x+(self.velocity.x*dt), y+(self.velocity.y*dt)

class SpiralMoveStrategy(MoveStrategy):

    def __init__(self, approachingAngle, angularSpeed, speed, ball):
        super(SpiralMoveStrategy, self).__init__(ball)
        self.angularSpeed = angularSpeed
        self.speed = speed
        self.distance = GAME_AREA_RADIUS
        self.angle = approachingAngle
        self.__setPos__()
        
    def __setPos__(self):
        x = self.distance*math.cos(self.angle)
        y = self.distance*math.sin(self.angle)
        self.ball.position = x, y
        
    def moveByDeltaTime(self, dt):
        self.angle += self.angularSpeed*dt
        self.distance -= self.speed*dt
        self.__setPos__()
        
class SinusMoveStrategy(MoveStrategy):

    def __init__(self, angularSpeed, horizontalSpeed, ball):
        super(SinusMoveStrategy, self).__init__(ball)
        self.angularSpeed = angularSpeed
        self.horizontalSpeed = horizontalSpeed
        self.angle = 0.0
        y = math.sin(self.angle)
        if horizontalSpeed < 0: x = GAME_AREA_RADIUS
        else: x = -GAME_AREA_RADIUS
        self.ball.sprite.position = x, y
    
    def moveByDeltaTime(self, dt):
        x, y = self.ball.position
        x += self.horizontalSpeed*dt
        self.angle += self.angularSpeed*dt
        y = math.sin(self.angle)*GAME_AREA_RADIUS
        self.ball.position = x, y

class BallAction(object):

    def __init__(self, gameLayer):
        self.gameLayer = gameLayer
        pass

class BallAction_Laser(BallAction):
    
    def __init__(self, gameLayer):
        super(BallAction_Laser, self).__init__(gameLayer)
    
    def __call__(self, ball):
        ballsToPop = []
        while ball.type != BALL_TYPE_CORE:
            if ball.goingToPop == False:
                ballsToPop.append(ball)
            ball = closestGrid(ball.hexagrid.neighbours).ball
        gameLayer.addToPoppingBalls(ballsToPop)

class BallAction_ClearRing(BallAction):

    def __init__(self, gameLayer):
        super(BallAction_Explode, self).__init__(gameLayer)
        self.depth = depth
        
    def __call__(self, ball):
        ring = self.gameLayer.hexameshLayer.hexamesh.rings[ball.hexagrid.distance]
        ballsToPop = [h.ball for h in ring if h.ball != None and h.ball.goingToPop == False]
        self.gameLayer.addToPoppingBalls(ballsToPop)
        
class Ball(object):

    idGenerator = IdGenerator()

    def __init__(self, type):
        self.id = self.idGenerator.next()
        self.sprite = Sprite(imageForBallType(type))
        self.sprite.position = 0, 0
        self.type = type

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
        assert self.moveStrategy != None
        self.moveStrategy.moveByDeltaTime(dt)