//
//  Logic.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"
#import <Foundation/Foundation.h>

@class GameModel;

@interface Level : NSObject {
    BOOL expired;
    NSArray* ballTypes;
    int ballsLeft;
    CGFloat ballSpeed;
    CGFloat createBallInterval;
    CGFloat createBallTimer;
}

@property (nonatomic, assign) BOOL expired;

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval;
- (void) execute:(CGFloat)dt;
- (void) ballsDestroyed:(NSArray*)aBalls;
- (BOOL) powerActionRequested;
- (NSString*) description;

@end

@interface LevelWithDistinctBalls : Level {
    BallType lastBallType;
    NSMutableArray* mutableBallTypes;
}

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval;
- (void) execute:(CGFloat)dt;
- (NSString*) description;

@end

@interface LevelWithSimultaneousBalls : Level {
    int simul;
    CGFloat angleStep;
    NSMutableArray* mutableBallTypes;
}

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval
                   simul:(int)aSimul;
- (void) execute:(CGFloat)dt;
- (NSString*) description;

@end