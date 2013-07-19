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
        NSAssert(aBall.sprite, @"Ball does not have a sprite");
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
    if ((self = [super init])) {
        ball = aBall;
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
