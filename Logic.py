from common import *
from Ball import *

import random

class Logic(object):

    def __init__(self, gameLayer):
        self.gameLayer = gameLayer

class Logic_Parallel_Execution(Logic):
    
    def __init__(self, gameLayer, logics):
        super(Logic_Parallel_Execution, self).__init__(gameLayer)
        self.logics = logics
    
    def __call__(self, dt):
        for l in self.logics: l(dt)
        
    def isExpired(self):
        return any(l.isExpired() for l in self.logics)

class Logic_CreateBall(Logic):

    def __init__(self, gameLayer, *args, **kargs):
        super(Logic_CreateBall, self).__init__(gameLayer)
        
        self.expired = False
        self.ballTypes = kargs['types']
        self.ballsLeft = kargs['repeat']
        self.ballSpeed = kargs['ballSpeed']
        self.createBallInterval = kargs['createBallInterval']
        self.createBallTimer = 0
    
class Logic_CreateBall_Simple(Logic_CreateBall):

    def __init__(self, gameLayer, *args, **kargs):
        super(Logic_CreateBall_Simple, self).__init__(gameLayer, *args, **kargs)

    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallTimer = 0.0
            ball = Ball(random.choice(self.ballTypes))
            angle = 2*math.pi*random.random()
            ball.moveStrategy = LineerMoveStrategy(angle, self.ballSpeed, ball);
            self.gameLayer.addBall(ball)
            self.ballsLeft -= 1
            if self.ballsLeft == 0:
                self.expired = True
                return
    
    def isExpired(self):
        return self.expired

class Logic_CreateBall_Distinct(Logic_CreateBall):

    def __init__(self, gameLayer, *args, **kargs):
        super(Logic_CreateBall_Distinct, self).__init__(gameLayer, *args, **kargs)
        self.lastBallType = self.ballTypes[0]

    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallTimer = 0.0
            temp = self.ballTypes[:]
            temp.remove(self.lastBallType)
            type = random.choice(temp)
            ball = Ball(type)
            self.lastBallType = type
            angle = 2*math.pi*random.random()
            ball.moveStrategy = LineerMoveStrategy(angle, self.ballSpeed, ball);
            self.gameLayer.addBall(ball)
            self.ballsLeft -= 1
            if self.ballsLeft == 0:
                self.expired = True
                return
    
    def isExpired(self):
        return self.expired

class Logic_CreateBall_Simultaneous(Logic_CreateBall_Simple):

    def __init__(self, gameLayer, *args, **kargs):
        super(Logic_CreateBall_Simultaneous, self).__init__(gameLayer, *args, **kargs)
        self.simul = kargs['simul']
        self.angleStep = 2*math.pi / self.simul
        
    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallTimer = 0.0
            angle = 2*math.pi*random.random()
            for type in random.sample(self.ballTypes, self.simul):
                ball = Ball(type)
                ball.moveStrategy = LineerMoveStrategy(angle, self.ballSpeed, ball)
                self.gameLayer.addBall(ball)
                angle += self.angleStep
            self.ballsLeft -= 1
            if self.ballsLeft == 0:
                self.expired = True
                return

class Logic_CreateBall_Simple_Sinus(Logic_CreateBall):

    def __init__(self, gameLayer, *args, **kargs):
        super(Logic_CreateBall_Simple_Sinus, self).__init__(gameLayer, *args, **kargs)
        self.angularSpeed = kargs['angularSpeed']
        
    def __call__(self, dt):
        self.createBallTimer += dt
        if (self.createBallTimer > self.createBallInterval):
            self.createBallTimer = 0.0
            ball = Ball(random.choice(self.ballTypes))
            ball.moveStrategy = SinusMoveStrategy(self.angularSpeed, random.choice([-1, 1])*self.ballSpeed, ball);
            self.gameLayer.addBall(ball)
            self.ballsLeft -= 1
            if self.ballsLeft == 0:
                self.expired = True
                return
    
    def isExpired(self):
        return self.expired
