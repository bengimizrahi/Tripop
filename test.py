import math

BALL_RADIUS = 10
FOUR_RADIUS_SQR = 400
attachedBalls = []

class Ball:
    def __init__(self, x, y):
	self.position = x, y
	self.prevPosition = x, y
	self.__horizontalDist = None
	self.__verticalDist = None
    
    def __repr__(self):
	return str(self.position)

def checkCollision(ball):
    def pdis(a, b, c):
	print "pdis(a=", a, ", b=", b, ", c=", c
	t = a[0]-b[0], a[1]-b[1]
	print "t=", t
	dd = math.sqrt(t[0]**2+t[1]**2)
	print "dd=", dd
	t = t[0]/dd, t[1]/dd
	print "unit t = ", t
	n = -t[1], t[0]
	print "n = ", n
	bc = c[0]-b[0], c[1]-b[1]
	print "bc = ", bc
	r = (dd, math.fabs(bc[0]*n[0]+bc[1]*n[1]), math.fabs(bc[0]*t[0]+bc[1]*t[1]))
	return r

    pos = ball.position
    prevPos = ball.prevPosition
    candidateBall = None
    for ab in attachedBalls:
	dd, ab.__verticalDist, ab.__horizontalDist = pdis(pos, prevPos, ab.position)
	print "dd, ab.__verticalDist, ab.__horizontalDist = ", dd, ab.__verticalDist, ab.__horizontalDist
	if ab.__verticalDist < 2*BALL_RADIUS:
	    print "ab.__verticalDist(%.2f) < 2*BALL_RADIUS" % ab.__verticalDist
	    if candidateBall == None or ab.__horizontalDist < candidateBall.__horizontalDist:
		actualHorizontalDist = ab.__horizontalDist - math.sqrt(FOUR_RADIUS_SQR - ab.__verticalDist**2)
		print "actualHorizontalDist = ", actualHorizontalDist
		if dd > actualHorizontalDist:
		    print "dd > actualHorizontalDist"
		    ab.__horizontalDist = actualHorizontalDist
		    candidateBall = ab
		    return candidateBall

if __name__ == "__main__":
    a = Ball(200, 0)
    a.prevPosition = 0, 0
    c = Ball(100, 19)
    attachedBalls.append(c)
    print checkCollision(a) 
