//
//  BallMoveStrategy.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ball;

@interface BallMoveStrategy : NSObject {
    Ball* ball;
}

- (id) initWithBall:(Ball*)aBall;
- (void) moveByDeltaTime:(CGFloat)dt;

@end

@interface LineerMoveStrategy : BallMoveStrategy {
    CGPoint normalizedVelocity;
    CGPoint velocity;
}

- (id) initWithBall:(Ball*)aBall 
      approachAngle:(CGFloat)aApproachAngle
              speed:(CGFloat)aSpeed;
- (void) moveByDeltaTime:(CGFloat)dt;
@end

@interface SinusMoveStrategy : BallMoveStrategy {
    CGFloat angularSpeed;
    CGFloat horizontalSpeed;
    CGFloat angle;
}

- (id) initWithBall:(Ball*)aBall
       angularSpeed:(CGFloat)aAngularSpeed
    horizontalSpeed:(CGFloat)aHorizontalSpeed;
- (void) moveByDeltaTime:(CGFloat)dt;
@end

@interface SpiralMoveStrategy : BallMoveStrategy {
    CGFloat angularSpeed;
    CGFloat speed;
    CGFloat distance;
    CGFloat angle;
}

- (id) initWithBall:(Ball*)aBall
      approachAngle:(CGFloat)aApproachAngle
       angularSpeed:(CGFloat)aAngularSpeed 
              speed:(CGFloat)aSpeed;
- (void) moveByDeltaTime:(CGFloat)dt;
@end
