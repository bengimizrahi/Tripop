//
//  Logic.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Level.h"

#import "BallMoveStrategy.h"
#import "Ball.h"
#import "SpaceLayer.h"
#import "GameModel.h"
#import "common.h"
#import "cocos2d.h"

@implementation Level

@synthesize expired, gameModel;

- (id) initWithBallTypes:(NSArray*)aBallTypes repeat:(int)aRepeat ballSpeed:(CGFloat)aBallSpeed createBallInterval:(CGFloat)aCreateBallInterval {
    if ((self = [super init])) {
        expired = NO;
        ballTypes = [aBallTypes retain];
        ballsLeft = aRepeat;
        ballSpeed = aBallSpeed;
        createBallInterval = aCreateBallInterval;
        createBallTimer = 0;
    }
    return self;
}

- (void) dealloc {
    [ballTypes release];

    [super dealloc];
}

- (void) execute:(CGFloat)dt {
    NSAssert(gameModel, @"gameModel is nil");
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        BallType type = [[ballTypes objectAtIndex:(int)(CCRANDOM_0_1() * [ballTypes count])] intValue];
        Ball* ball = [[Ball alloc] initWithType:type];
        CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
        BallMoveStrategy* aBallMoveStrategy = [[LineerMoveStrategy alloc] initWithBall:ball approachAngle:angle speed:ballSpeed];
        ball.moveStrategy = aBallMoveStrategy;
        [aBallMoveStrategy release];
        ballsLeft -= 1;
        if (ballsLeft == 0) {
            expired = YES;
        }
        [gameModel.freeBalls addObject:ball];
        [gameModel.spaceLayer addChild:ball.node];
        [ball release];
    }
}

- (NSString*) description {
    NSString* a[5] = {@"C", @"R", @"G", @"B", @"Y"};
    NSMutableString* bt_str = [[NSMutableString alloc] init];
    for (NSNumber* num in ballTypes) {
        BallType bt = [num intValue];
        [bt_str appendString:a[bt]];
    }
    NSMutableString* str = [[NSMutableString alloc] initWithFormat:@"Level([%@] repeat=%d ballSpeed=%.2f createBallInterval=%.2f)", bt_str, ballSpeed, createBallInterval];
    return str;
}

@end

@implementation LevelWithDistinctBalls

- (id) initWithBallTypes:(NSArray*)aBallTypes repeat:(int)aRepeat ballSpeed:(CGFloat)aBallSpeed createBallInterval:(CGFloat)aCreateBallInterval {
    if ((self = [super initWithBallTypes:aBallTypes repeat:aRepeat ballSpeed:aBallSpeed createBallInterval:aCreateBallInterval])) {
        lastBallType = [[ballTypes objectAtIndex:0] intValue];
        mutableBallTypes = [[NSMutableArray alloc] initWithArray:ballTypes];
    }
    return self;
}

- (void) execute:(CGFloat)dt {
    NSAssert(gameModel, @"gameModel is nil");
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        [mutableBallTypes removeObject:[NSNumber numberWithInt:lastBallType]];
        int i = (int)(CCRANDOM_0_1() * [mutableBallTypes count]);
        BallType type = [[mutableBallTypes objectAtIndex:i] intValue];
        [mutableBallTypes addObject:[NSNumber numberWithInt:lastBallType]];
        lastBallType = type;
        Ball* ball = [[Ball alloc] initWithType:type];
        CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
        BallMoveStrategy* aBallMoveStrategy = [[LineerMoveStrategy alloc] initWithBall:ball approachAngle:angle speed:ballSpeed];
        ball.moveStrategy = aBallMoveStrategy;
        [aBallMoveStrategy release];
        ballsLeft -= 1;
        if (ballsLeft == 0) {
            expired = YES;
        }
        [gameModel.freeBalls addObject:ball];
        [gameModel.spaceLayer addChild:ball.node];
        [ball release];
    }
}

- (NSString*) description {
    return [NSString stringWithFormat:@"LevelWithDistinctBalls : %@", [super description]];
}

@end

@implementation LevelWithSimultaneousBalls

- (id) initWithBallTypes:(NSArray*)aBallTypes repeat:(int)aRepeat ballSpeed:(CGFloat)aBallSpeed createBallInterval:(CGFloat)aCreateBallInterval simul:(int)aSimul {
    if ((self = [super initWithBallTypes:aBallTypes repeat:aRepeat ballSpeed:aBallSpeed createBallInterval:aCreateBallInterval])) {
        simul = aSimul;
        angleStep = 2 * M_PI / simul;
        mutableBallTypes = [[NSMutableArray alloc] initWithArray:ballTypes];
    }
    return self;
}

- (void) execute:(CGFloat)dt {
    NSAssert(gameModel, @"gameModel is nil");
    createBallTimer += dt;
    if (createBallTimer > createBallInterval) {
        createBallTimer = 0.0f;
        shuffle(mutableBallTypes);
        CGFloat angle = CCRANDOM_0_1() * (2*M_PI);
        for (int i = 0; i < simul; ++i) {
            Ball* ball = [[Ball alloc] initWithType:[[mutableBallTypes objectAtIndex:i] intValue]];
            BallMoveStrategy* aBallMoveStrategy = [[LineerMoveStrategy alloc] initWithBall:ball approachAngle:angle speed:ballSpeed];
            ball.moveStrategy = aBallMoveStrategy;
            [aBallMoveStrategy release];
            angle += angleStep;
            [gameModel.freeBalls addObject:ball];
            [gameModel.spaceLayer addChild:ball.node];
            [ball release];
        }        
        ballsLeft -= 1;
        if (ballsLeft == 0) {
            expired = YES;
        }
    }
}

- (NSString*) description {
    NSString* a[5] = {@"C", @"R", @"G", @"B", @"Y"};
    NSMutableString* bt_str = [[NSMutableString alloc] init];
    for (NSNumber* num in ballTypes) {
        BallType bt = [num intValue];
        [bt_str appendString:a[bt]];
    }
    NSMutableString* str = [[NSMutableString alloc] initWithFormat:@"Level([%@] repeat=%d ballSpeed=%.2f createBallInterval=%.2f)", bt_str, ballSpeed, createBallInterval];
    return str;
}

@end
