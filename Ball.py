from common import *
from cocos.euclid import *
from cocos.sprite import Sprite

def createBall(approachingAngle, speed, type):
   x = GAME_AREA_RADIUS*math.cos(approachingAngle)
   y = GAME_AREA_RADIUS*math.sin(approachingAngle)
   newBall = Ball(x, y, speed, type)
   return newBall

class Ball:
    def __init__(self, x, y, speed, type):
	self.sprite = Sprite(imageForBallType(type))
	self.setPosition(x, y)
	self.type = type
	self.velocity = Vector2(-x, -y).normalize()*speed
	self.hexagrid = None
    def __repr__(self):
	return "[B:%.2f,%.2f,%s]" % (self.x, self.y, self.velocity)
    def setPosition(self, x, y):
	assert hasattr(self, 'sprite')
	self.x, self.y = x, y
	self.sprite.position = x, y
    def position(self):
	return self.x, self.y
    def distance(self, ball):
	x1, y1 = self.position()
	x2, y2 = ball.position()
	return math.sqrt((x1-x2)**2 + (y1-y2)**2)
    def angleTo(self, ball):
	x1, y1 = self.position()
	x2, y2 = ball.position()
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
	x, y = self.position()
	self.setPosition(x+(self.velocity.x*dt), y+(self.velocity.y*dt))
    def conenct(self):
	assert True, "NOT IMPLEMENTED"
    def connect(self, ball):
	angle = self.angleTo(ball)
	x1, y1 = self.position()
	x2, y2 = ball.position()
	x = x2-x1
	y = y2-y1
	if x > 0 and y >= 0 and 0 <= angle < math.pi/3:
	    nb_idx = 3
	    x2 = 2*BALL_RADIUS*math.cos(math.pi/6)+x1
	    y2 = 2*BALL_RADIUS*math.sin(math.pi/6)+y1
	elif y >= 0 and math.pi/3 <= angle < 2*math.pi/3:
	    nb_idx = 4
	    x2 = x1
	    y2 = 2*BALL_RADIUS+y1
	elif x < 0 and y >= 0 and 2*math.pi/3 <= angle < math.pi:
	    nb_idx = 5
	    x2 = 2*BALL_RADIUS*math.cos(5*math.pi/6)+x1
	    y2 = 2*BALL_RADIUS*math.sin(5*math.pi/6)+y1
	elif x < 0 and y < 0 and math.pi <= angle < 4*math.pi/3:
	    nb_idx = 0
	    x2 = 2*BALL_RADIUS*math.cos(7*math.pi/6)+x1
	    y2 = 2*BALL_RADIUS*math.sin(7*math.pi/6)+y1
	elif y < 0 and 4*math.pi/3 <= angle < 5*math.pi/3:
	    nb_idx = 1
	    x2 = x1
	    y2 = -2*BALL_RADIUS+y1
	elif y < 0 and 5*math.pi/3 <= angle < 2*math.pi:
	    nb_idx = 2
	    x2 = 2*BALL_RADIUS*math.cos(11*math.pi/6)+x1
	    y2 = 2*BALL_RADIUS*math.sin(11*math.pi/6)+y1
	else:
	    assert True, "connect error"
	ball.setPosition(x2, y2)
	nb_hexagrid = self.hexagrid.neighbours[nb_idx]
	if nb_hexagrid == None:
	    print "GAME OVER :))))"
	    return
	nb_hexagrid.ball = ball
	ball.hexagrid = nb_hexagrid
	ball.velocity *= 0
	#ball.connect()
