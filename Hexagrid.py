from common import *
from Ball import *

class Hexagrid:

    idGenerator = IdGenerator()

    def __init__(self):
        self.neighbours = [None]*6
        self.ball = None
	self.dirty = False
        self.id = Hexagrid.idGenerator.next()

    def setBall(self, ball):
        self.ball = ball 
        if ball != None:
            ball.hexagrid = self 

    def sameColorGroup(self):
        assert self.ball != None
        self.dirty = True
        group = [self]
        arr = [self]
        num = 1
        while len(arr) > 0:
            h = arr.pop()
            for n in h.neighbours:
                if n.ball != None and n.ball.type == self.ball.type and n.dirty != True:
                    arr.append(n)
                    group.append(n)
                    n.dirty = True
                    num += 1
        for h in group: h.dirty = False
        return group
    
    def __repr__(self):
        return "[H:%d]" % self.id

class Hexamesh:

    def __init__(self, level, hexameshLayer):
        self.level = level
        self.hexameshLayer = hexameshLayer

        def connect_2and5(arrayx):
            assert len(arrayx) > 0
            for i in xrange(len(arrayx)-1):
                h1 = arrayx[i]
                h2 = arrayx[i+1]
                h1.neighbours[5] = h2
                h2.neighbours[2] = h1
                
        def connect_1and4(arrayx_l, arrayx_u, offsetl=0, offsetu=0):
            assert len(arrayx_l)+offsetl > 0
            assert len(arrayx_u)+offsetu > 0
            i = 0
            while i < min(len(arrayx_l), len(arrayx_u)):
                hl = arrayx_l[i+offsetl]
                hu = arrayx_u[i+offsetu]
                hl.neighbours[1] = hu
                hu.neighbours[4] = hl
                i += 1

        def connect_0and3(arrayx_l, arrayx_u, offsetl=0, offsetu=0):
            assert len(arrayx_l)+offsetl > 0
            assert len(arrayx_u)+offsetu > 0
            i = 0
            while i < min(len(arrayx_l), len(arrayx_u)):
                hl = arrayx_l[i+offsetl]
                hu = arrayx_u[i+offsetu]
                hl.neighbours[0] = hu
                hu.neighbours[3] = hl
                i += 1
        
        def setDistances(arrayx, level, vdist):
            sub = level - vdist
            arr = []
            for i in xrange(sub):
                arr.append(level-i)
            for i in xrange(len(arrayx)-2*sub-1):
                arr.append(level-sub)
            for i in xrange(sub, -1, -1):
                arr.append(level-i)
            for i in xrange(len(arrayx)):
                arrayx[i].distance = arr[i]

        arrayy = []
        last_arrayx = None
        for i in xrange(level+1, 2*(level+1)):
            arrayx = [Hexagrid() for c in xrange(i)]
            setDistances(arrayx, level, 2*(level+1)-1-i)
            connect_2and5(arrayx)
            if last_arrayx != None:
                connect_1and4(last_arrayx, arrayx)
                connect_0and3(last_arrayx, arrayx, offsetl=0, offsetu=1)
            last_arrayx = arrayx
            arrayy.append(arrayx)
        for i in xrange(2*level, level, -1):
            arrayx = [Hexagrid() for c in xrange(i)]
            setDistances(arrayx, level, 2*(level+1)-1-i)
            connect_2and5(arrayx)
            connect_1and4(last_arrayx, arrayx, offsetl=1, offsetu=0)
            connect_0and3(last_arrayx, arrayx)
            last_arrayx = arrayx
            arrayy.append(arrayx)
        h = arrayy[0][0]
        for i in xrange(level):
            h = h.neighbours[0]
        self.center = h
        self.center.setBall(Ball(0, 0, 0, BALL_TYPE_CORE))

def test_buildHexagrid(level):
    hexamesh = Hexamesh(level)
    print hexamesh.center.id
    print hexamesh.center.neighbours[0].id
    print hexamesh.center.neighbours[0].neighbours[0].id
    print hexamesh.center.neighbours[0].neighbours[0].neighbours[0].id

if __name__ == "__main__":
    test_buildHexagrid(3)
