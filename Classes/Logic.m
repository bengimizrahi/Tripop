//
//  Logic.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Logic.h"

#import "BallMoveStrategy.h"
#import "Ball.h"
#import "SpaceLayer.h"
#import "GameModel.h"
#import "common.h"
#import "cocos2d.h"

@implementation Logic

- (void) encodeWithCoder:(NSCoder*)aCoder {
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
    }
    return self;
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    NSAssert(NO, @"Should not call this");
    return NO;
}

@end

@implementation Logic_Parallel

- (id) initWithLogics:(Logic*)logic, ... {
    if ((self = [super init])) {
        logics = [[NSMutableArray alloc] initWithObjects:logic, nil];
        Logic* l;
        va_list params;
        va_start(params, logic);
        while (logic) {
            l = va_arg(params, Logic*);
            if (l) {
                [logics addObject:l];
            } else {
                break;
            }
        }
        va_end(params);
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:logics forKey:@"logics"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    logics = [[aDecoder decodeObjectForKey:@"logics"] retain];
    return self;
}

- (void) dealloc {
    [logics release];
    [super dealloc];
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    BOOL levelRunning = YES;
    for (Logic* l in logics) {
        if (![l execute:dt gameModel:aGameModel]) {
            levelRunning = NO;
        }
    }
    return levelRunning;
}

@end

@implementation Logic_Forever

- (id) initWithLogic:(Logic*)aLogic {
    if ((self = [super init])) {
        logic = [aLogic retain];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:logic forKey:@"logic"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    logic = [[aDecoder decodeObjectForKey:@"logic"] retain];
    return self;
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    [logic execute:dt gameModel:aGameModel];
    return YES;
}

@end

@implementation Logic_CreateBall_Simple

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval {
    if ((self = [super init])) {
        ballTypes = [aBallTypes retain];
        ballsLeft = aRepeat;
        ballSpeed = aBallSpeed;
        createBallInterval = aCreateBallInterval;
        createBallTimer = 0.0f;        
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:ballTypes forKey:@"ballTypes"];
    [aCoder encodeInt:ballsLeft forKey:@"ballsLeft"];
    [aCoder encodeFloat:ballSpeed forKey:@"ballSpeed"];
    [aCoder encodeFloat:createBallInterval forKey:@"createBallInterval"];
    [aCoder encodeFloat:createBallTimer forKey:@"createBallTimer"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    ballTypes = [[aDecoder decodeObjectForKey:@"ballTypes"] retain];
    ballsLeft = [aDecoder decodeIntForKey:@"ballsLeft"];
    ballSpeed = [aDecoder decodeFloatForKey:@"ballSpeed"];
    createBallInterval = [aDecoder decodeFloatForKey:@"createBallInterval"];
    createBallTimer = [aDecoder decodeFloatForKey:@"createBallTimer"];
    return self;
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        BallType type = [[ballTypes objectAtIndex:(int)(CCRANDOM_0_1() * [ballTypes count])] intValue];
        Ball* ball = [[Ball alloc] initWithType:type gameModel:aGameModel];
        ball.points = 5;
        ball.power = 1.0f;
        CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
        BallMoveStrategy* aBallMoveStrategy = [[LineerMoveStrategy alloc] initWithBall:ball approachAngle:angle speed:ballSpeed];
        ball.moveStrategy = aBallMoveStrategy;
        [aBallMoveStrategy release];
        ballsLeft -= 1;
        [aGameModel.freeBalls addObject:ball];
        [aGameModel.spaceLayer addChild:ball.node];
        [ball release];
        if (ballsLeft == 0) {
            return NO;
        }
    }
    return YES;
}

@end


@implementation Logic_CreateBall_Distinct

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval {
    if ((self = [super initWithBallTypes:aBallTypes
                                  repeat:aRepeat
                               ballSpeed:aBallSpeed
                      createBallInterval:aCreateBallInterval])) {
        lastBallType = [[ballTypes objectAtIndex:0] intValue];
        mutableBallTypes = [[NSMutableArray alloc] initWithArray:ballTypes];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:lastBallType forKey:@"lastBallType"];
    [aCoder encodeObject:mutableBallTypes forKey:@"mutableBallTypes"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    lastBallType = [aDecoder decodeIntForKey:@"lastBallType"];
    mutableBallTypes = [[aDecoder decodeObjectForKey:@"mutableBallTypes"] retain];
    return self;
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        [mutableBallTypes removeObject:[NSNumber numberWithInt:lastBallType]];
        int i = (int)(CCRANDOM_0_1() * [mutableBallTypes count]);
        BallType type = [[mutableBallTypes objectAtIndex:i] intValue];
        [mutableBallTypes addObject:[NSNumber numberWithInt:lastBallType]];
        lastBallType = type;
        Ball* ball = [[Ball alloc] initWithType:type gameModel:aGameModel];
        ball.points = 5;
        ball.power = 1.0f;
        CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
        BallMoveStrategy* aBallMoveStrategy = [[LineerMoveStrategy alloc] initWithBall:ball approachAngle:angle speed:ballSpeed];
        ball.moveStrategy = aBallMoveStrategy;
        [aBallMoveStrategy release];
        ballsLeft -= 1;
        [aGameModel.freeBalls addObject:ball];
        [aGameModel.spaceLayer addChild:ball.node];
        [ball release];
        if (ballsLeft == 0) {
            return NO;
        }
    }
    return YES;
}

@end


@implementation Logic_CreateBall_Simultaneous

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval
                   simul:(int)aSimul {
    if ((self = [super initWithBallTypes:aBallTypes
                                  repeat:aRepeat
                               ballSpeed:aBallSpeed
                      createBallInterval:aCreateBallInterval])) {
        simul = aSimul;
        angleStep = 2 * M_PI / simul;
        mutableBallTypes = [[NSMutableArray alloc] initWithArray:ballTypes];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:simul forKey:@"simul"];
    [aCoder encodeFloat:angleStep forKey:@"angleStep"];
    [aCoder encodeObject:mutableBallTypes forKey:@"mutableBallTypes"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    simul = [aDecoder decodeIntForKey:@"simul"];
    angleStep = [aDecoder decodeFloatForKey:@"angleStep"];
    mutableBallTypes = [[aDecoder decodeObjectForKey:@"mutableBallTypes"] retain];
    return self;
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        shuffle(mutableBallTypes);
        CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
        for (int i = 0; i < simul; ++i) {
            Ball* ball = [[Ball alloc] initWithType:[[mutableBallTypes objectAtIndex:i] intValue] gameModel:aGameModel];
            ball.points = 5;
            ball.power = 1.0f;
            BallMoveStrategy* aBallMoveStrategy = [[LineerMoveStrategy alloc] initWithBall:ball approachAngle:angle speed:ballSpeed];
            ball.moveStrategy = aBallMoveStrategy;
            [aBallMoveStrategy release];
            angle += angleStep;
            [aGameModel.freeBalls addObject:ball];
            [aGameModel.spaceLayer addChild:ball.node];
            [ball release];
        }        
        ballsLeft -= 1;
        if (ballsLeft == 0) {
            return NO;
        }
    }
    return YES;
}

@end


@implementation Logic_CreateBall_Sinus

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval
            angularSpeed:(CGFloat)aAngularSpeed {
    if ((self = [super initWithBallTypes:aBallTypes
                                  repeat:aRepeat
                               ballSpeed:aBallSpeed
                      createBallInterval:aCreateBallInterval])) {
        angularSpeed = aAngularSpeed;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeFloat:angularSpeed forKey:@"angularSpeed"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    angularSpeed = [aDecoder decodeFloatForKey:@"angularSpeed"];
    return self;
}

- (BOOL) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        BallType type = [[ballTypes objectAtIndex:(int)(CCRANDOM_0_1() * [ballTypes count])] intValue];
        Ball* ball = [[Ball alloc] initWithType:type gameModel:aGameModel];
        ball.points = 5;
        ball.power = 1.0f;
        int dir = 1;
        if (CCRANDOM_MINUS1_1() < 0) {
            dir = -1;
        }
        BallMoveStrategy* aBallMoveStrategy = [[SinusMoveStrategy alloc] initWithBall:ball angularSpeed:angularSpeed horizontalSpeed:dir*ballSpeed];
        ball.moveStrategy = aBallMoveStrategy;
        [aBallMoveStrategy release];
        ballsLeft -= 1;
        [aGameModel.freeBalls addObject:ball];
        [aGameModel.spaceLayer addChild:ball.node];
        [ball release];
        if (ballsLeft == 0) {
            return NO;
        }
    }
    return YES;
}

@end
