from cocos.director import director
from cocos.layer import *
from cocos.scene import Scene
from cocos.sprite import Sprite
from cocos.euclid import *
from cocos.actions.interval_actions import *

import pyglet

class GameLayer(Layer):
    def __init__(self):
	super(GameLayer, self).__init__()
	width, height = director.get_window_size()
	self.children_anchor = width/2,height/2
	self.sprite = Sprite('Images/Core.png')
	self.sprite.position = 10, 0
	self.add(self.sprite)
	self.schedule(self.step)
    def step(self, dt):
	self.do(RotateBy(2, 0))
	x, y = self.sprite.position
	angle = self.rotation / 360.0 * 2 * math.pi
	print (x*math.cos(angle) + y*math.sin(angle), -x*math.sin(angle) + y*math.cos(angle)) 

if __name__ == "__main__":
    director.init(width=80, height=80, resizable=True)
    director.run(Scene(GameLayer()))

