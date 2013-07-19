//
//  Logic.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

#import <Foundation/Foundation.h>

@class GameModel;

@interface Logic : NSObject<NSCoding> {    
}

- (void) encodeWithCoder:(NSCoder*)aCoder;
- (id) initWithCoder:(NSCoder*)aDecoder;

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel;

@end

@interface Logic_Parallel : Logic {
    NSMutableArray* logics;    
}

- (id) initWithLogics:(Logic*)logic, ...;

@end

@interface Logic_Forever : Logic {
    Logic* logic;
}

- (id) initWithLogic:(Logic*)logic;

@end

@interface Logic_CreateBall_Simple : Logic {
    NSArray* ballTypes;
    int ballsLeft;
    CGFloat ballSpeed;
    CGFloat createBallInterval;
    CGFloat createBallTimer;
}

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval;
@end

@interface Logic_CreateBall_Distinct : Logic_CreateBall_Simple
{
    BallType lastBallType;
    NSMutableArray* mutableBallTypes;
}

@end

@interface Logic_CreateBall_Simultaneous : Logic_CreateBall_Simple {
    int simul;
    CGFloat angleStep;
    NSMutableArray* mutableBallTypes;    
}

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval
                   simul:(int)aSimul;
    
@end

@interface Logic_CreateBall_Sinus : Logic_CreateBall_Simple {
    CGFloat angularSpeed;
}

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval
            angularSpeed:(CGFloat)aAngularSpeed;

@end
