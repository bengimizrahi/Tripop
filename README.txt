- Make sure -fmath flag is ON.
More info:
http://gamesfromwithin.com/break-that-thumb-for-best-iphone-performance

- Use the fastest texture format. (Consider using a TextureManager)
- Try using CADisplayLink Director. (Also check out FastDirector)
- You can use this to shake the core, when it is full power: [self actionWithRange:5 shakeZ:YES grid:ccg(15,10) duration:t]
- Use AtlasLabel instead of Label.
- Introduce Level protocol:
    - (void) step:(int)dt;
    - (void) createBall;
    - (void) onScreenCleared;

- Add field ballAction, to override popping effect.
- Spawn, Sequence, DelayTime, CallFuncN actions can be feneficial. Figure out how to use CallFuncN action to release a Ball.
