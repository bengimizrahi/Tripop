//
//  BallMoveStrategy.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BallMoveStrategy.h"

#import "Ball.h"
#import "common.h"
#import "cocos2d.h"

@implementation BallMoveStrategy

- (id) initWithBall:(Ball*)aBall {
    if ((self = [super init])) {
        NSAssert(aBall.node, @"Ball does not have a CocosNode");
        ball = aBall;
    }
    return self;
}

- (void) moveByDeltaTime:(CGFloat)dt {
    NSAssert(NO, @"override");
}

@end

@implementation LineerMoveStrategy

- (id) initWithBall:(Ball*)aBall 
      approachAngle:(CGFloat)aApproachAngle
              speed:(CGFloat)aSpeed {
    if ((self = [super initWithBall:aBall])) {
        CGPoint v = ccpForAngle(aApproachAngle);
        ball.position = ccpMult(v, GAME_AREA_RADIUS);
        normalizedVelocity = ccpNeg(v);
        velocity = ccpMult(normalizedVelocity, aSpeed);
    }
    return self;
}

- (void) moveByDeltaTime:(CGFloat)dt {
    ball.position = ccpAdd(ball.position, ccpMult(velocity, dt));
}

@end

@implementation SinusMoveStrategy

- (id) initWithBall:(Ball*)aBall
       angularSpeed:(CGFloat)aAngularSpeed
    horizontalSpeed:(CGFloat)aHorizontalSpeed {
    if ((self = [super initWithBall:aBall])) {
        angularSpeed = aAngularSpeed;
        horizontalSpeed = aHorizontalSpeed;
        angle = 0.0f;
        ball.position = ccp(-1 * horizontalSpeed / abs(horizontalSpeed) * GAME_AREA_RADIUS, 0.0f);
    }
    return self;
}

- (void) moveByDeltaTime:(CGFloat)dt {
    angle += angularSpeed * dt;
    ball.position = ccp(ball.position.x + horizontalSpeed * dt, sinf(angle)*GAME_AREA_RADIUS);
}

@end

@implementation SpiralMoveStrategy

- (id) initWithBall:(Ball*)aBall
      approachAngle:(CGFloat)aApproachAngle
       angularSpeed:(CGFloat)aAngularSpeed 
              speed:(CGFloat)aSpeed {
    if ((self = [super initWithBall:aBall])) {
        angularSpeed = aAngularSpeed; 
        speed = aSpeed;
        distance = GAME_AREA_RADIUS;
        angle = aApproachAngle;
        ball.position = ccpMult(ccpForAngle(angle), distance);
    }
    return self;
}

- (void) moveByDeltaTime:(CGFloat)dt {
    angle += angularSpeed * dt;
    distance -= speed * dt;
    ball.position = ccpMult(ccpForAngle(angle), distance);
}

@end
