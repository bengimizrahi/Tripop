//
//  LevelDirector.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LevelDirector.h"

#import "Ball.h"
#import "BallMoveStrategy.h"
#import "Dynamite.h"
#import "Lightning.h"
#import "Logic.h"
#import "GameModel.h"
#import "PowerBar.h"
#import "InfoLayer.h"
#import "common.h"

@implementation LevelDirector

- (id) init {
    if ((self = [super init])) {
        idx = 0;
        logics = nil;
    }
    return self;
}

- (void) dealloc {
    [logics release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeInt:idx forKey:@"idx"];
    [aCoder encodeObject:logics forKey:@"logics"];
}

- (id)initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
        idx = [aDecoder decodeIntForKey:@"idx"];
        logics = [[aDecoder decodeObjectForKey:@"logics"] retain];
    }
    return self;
}

- (void) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    NSAssert(NO, @"Should not call this");
}

- (BOOL) powerActionRequested:(GameModel*)aGameModel {
    NSAssert(NO, @"Should not call this");
    return NO;
}

@end

@implementation StandardLevelDirector

- (id) init {
    if ((self = [super init])) {
        BallType ballTypes[4] = {BallType_Red, BallType_Green, BallType_Blue, BallType_Yellow};
        NSMutableArray* arr = shuffle(convertToNSArray(ballTypes, 4));
        Logic* logic1 = [[[Logic_CreateBall_Simple alloc] initWithBallTypes:[arr subarrayWithRange:NSMakeRange(0, 2)]
                                                                     repeat:30
                                                                  ballSpeed:70.0f
                                                         createBallInterval:1.0f] autorelease];
        Logic* logic2 = [[[Logic_CreateBall_Simple alloc] initWithBallTypes:[arr subarrayWithRange:NSMakeRange(0, 3)]
                                                                     repeat:30
                                                                  ballSpeed:70.0f
                                                         createBallInterval:1.0f] autorelease];
        Logic* logic3 = [[[Logic_CreateBall_Simple alloc] initWithBallTypes:arr
                                                                     repeat:60
                                                                  ballSpeed:70.0f
                                                         createBallInterval:1.0f] autorelease];
        Logic* logic4 = [[[Logic_CreateBall_Distinct alloc] initWithBallTypes:arr
                                                                       repeat:60
                                                                    ballSpeed:70.0f
                                                           createBallInterval:1.0f] autorelease];
        NSArray* warmups = [NSArray arrayWithObjects:logic1, logic2, logic3, logic4, nil];
        
        Logic* logic5 = [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                          repeat:30
                                                                       ballSpeed:70.0f
                                                              createBallInterval:2.0f
                                                                           simul:2] autorelease];
        Logic* logic6 = [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                           repeat:20
                                                                        ballSpeed:70.0f
                                                               createBallInterval:3.0f
                                                                            simul:3] autorelease];
        Logic* logic7 = [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                           repeat:30
                                                                        ballSpeed:70.0f
                                                               createBallInterval:2.0f
                                                                            simul:3] autorelease];
        Logic* logic8 = [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                           repeat:17
                                                                        ballSpeed:70.0f
                                                               createBallInterval:4.0f
                                                                            simul:4] autorelease];
        Logic* logic9 = [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                           repeat:20
                                                                        ballSpeed:70.0f
                                                               createBallInterval:3.0f
                                                                            simul:4] autorelease];
        Logic* logic10 = [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                            repeat:30
                                                                         ballSpeed:70.0f
                                                                createBallInterval:2.0f
                                                                             simul:4] autorelease];
        NSArray* simults = [NSArray arrayWithObjects:logic5, logic6, logic7, logic8, logic9, logic10, nil];

        Logic* logic11 = [[[Logic_CreateBall_Distinct alloc] initWithBallTypes:arr
                                                                        repeat:30
                                                                     ballSpeed:70.0f
                                                            createBallInterval:1.0f] autorelease];
        Logic* logic12 = [[[Logic_Parallel alloc] initWithLogics:
                           [[[Logic_CreateBall_Distinct alloc] initWithBallTypes:arr
                                                                          repeat:180
                                                                       ballSpeed:70.0f
                                                              createBallInterval:1.0f] autorelease],
                           [[[Logic_CreateBall_Sinus alloc] initWithBallTypes:arr
                                                                       repeat:45
                                                                    ballSpeed:20.0f
                                                           createBallInterval:4.0f
                                                                 angularSpeed:M_PI_2] autorelease], nil] autorelease];
        Logic* logic13 = [[[Logic_Parallel alloc] initWithLogics:
                           [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                          repeat:90
                                                                       ballSpeed:70.0f
                                                              createBallInterval:2.0f
                                                                           simul:2] autorelease],
                           [[[Logic_CreateBall_Sinus alloc] initWithBallTypes:arr
                                                                       repeat:45
                                                                    ballSpeed:20.0f
                                                           createBallInterval:4.0f
                                                                 angularSpeed:M_PI_2] autorelease], nil] autorelease];
        Logic* logic14 = [[[Logic_Parallel alloc] initWithLogics:
                           [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                              repeat:180
                                                                           ballSpeed:70.0f
                                                                  createBallInterval:1.0f
                                                                               simul:2] autorelease],
                           [[[Logic_CreateBall_Sinus alloc] initWithBallTypes:arr
                                                                       repeat:45
                                                                    ballSpeed:20.0f
                                                           createBallInterval:4.0f
                                                                 angularSpeed:M_PI_2] autorelease], nil] autorelease];
        Logic* logic15 = [[[Logic_Parallel alloc] initWithLogics:
                           [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                              repeat:90
                                                                           ballSpeed:70.0f
                                                                  createBallInterval:2.0f
                                                                               simul:3] autorelease],
                           [[[Logic_CreateBall_Sinus alloc] initWithBallTypes:arr
                                                                       repeat:45
                                                                    ballSpeed:20.0f
                                                           createBallInterval:4.0f
                                                                 angularSpeed:M_PI_2] autorelease], nil] autorelease];
        Logic* logic16 = [[[Logic_Parallel alloc] initWithLogics:
                           [[[Logic_CreateBall_Simultaneous alloc] initWithBallTypes:arr
                                                                              repeat:90
                                                                           ballSpeed:70.0f
                                                                  createBallInterval:2.0f
                                                                               simul:4] autorelease],
                           [[[Logic_CreateBall_Sinus alloc] initWithBallTypes:arr
                                                                       repeat:45
                                                                    ballSpeed:20.0f
                                                           createBallInterval:4.0f
                                                                 angularSpeed:M_PI_3] autorelease],
                           [[[Logic_CreateBall_Sinus alloc] initWithBallTypes:arr
                                                                       repeat:30
                                                                    ballSpeed:20.0f
                                                           createBallInterval:6.0f
                                                                 angularSpeed:M_PI_2] autorelease], nil] autorelease];
        Logic* logic16_forever = [[[Logic_Forever alloc] initWithLogic:logic16] autorelease];
        
        NSArray* sinusesAdded = [NSArray arrayWithObjects:logic11, logic12, logic13, logic14, logic15, logic16_forever, nil];

        logics = [[NSMutableArray alloc] init];
        [logics addObjectsFromArray:warmups];
        [logics addObjectsFromArray:simults];
        [logics addObjectsFromArray:sinusesAdded];
    }
    return self;
}

- (void) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel {
    Logic* logic = [logics objectAtIndex:idx];
    if (![logic execute:dt gameModel:aGameModel]) {
        idx++;
    }
}

- (BOOL) powerActionRequested:(GameModel*)aGameModel {
    CGFloat power = aGameModel.infoLayer.powerBar.power;
    if (power == 0) {
        return NO;
    }
    Ball* ball;
    if (0 < power && power <= 25) {
        ball = [[Dynamite alloc] initWithInpectLevel:1 gameModel:aGameModel];
    } else if (25 < power && power <= 50) {
        ball = [[Dynamite alloc] initWithInpectLevel:2 gameModel:aGameModel];
    } else if (50 < power && power <= 75) {
        ball = [[Dynamite alloc] initWithInpectLevel:3 gameModel:aGameModel];
    } else if (75 <= power) {
        ball = [[Lightning alloc] initWithGameModel:aGameModel];
    }
    CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
    BallMoveStrategy* aBallMoveStrategy = [[SpiralMoveStrategy alloc] initWithBall:ball approachAngle:angle angularSpeed:M_PI_4 speed:15];
    ball.moveStrategy = aBallMoveStrategy;
    [aBallMoveStrategy release];
    [aGameModel.freeBalls addObject:ball];
    [aGameModel.spaceLayer addChild:ball.node];
    [ball release];
    return YES;
}

@end
