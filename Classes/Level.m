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
        [gameModel addFreeBall:ball];
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