//
//  Dynamite.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"
#import "Grid.h"
#import "Dynamite.h"
#import "common.h"
#import "cocos2d.h"
#import "GameModel.h"
#import "TripopAppDelegate.h"

@implementation Dynamite

- (id) initWithInpectLevel:(int)aLevel gameModel:(GameModel*)aGameModel {
    if ((self = [super initWithType:BallType_Dynamite gameModel:aGameModel])) {
        inpectLevel = aLevel;
        [self resumeActions];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:inpectLevel forKey:@"inpectLevel"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    inpectLevel = [aDecoder decodeIntForKey:@"inpectLevel"];
    [self resumeActions];
    return self;
} 

- (void) __destroy {
    // removed -> [gameModel.ballsJustDestroyed addObject:self];
    [gameModel.attachedBalls removeObject:self];
    [gameModel.hexameshLayer removeChild:self.node cleanup:YES];
    self.grid.ball = nil;
}

- (void) pauseActions {
    [node stopActionByTag:ACTION_ROTATE_FOREVER];
}

- (void) resumeActions {
    Action* action = [RepeatForever actionWithAction:[RotateBy actionWithDuration:0.25f angle:360]];
    action.tag = ACTION_ROTATE_FOREVER;
    [node runAction:action];
}

- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall {
    [delegate playExplosionWithDelay:0.2f];
    Grid* h = aAttachedBall.grid;
    NSArray* rings = [h ringsToLevel:inpectLevel];
    for (int i = 0; i < [rings count]; ++i) {
        NSArray* ring = [rings objectAtIndex:i];
        for (Grid* rh in ring) {
            if (rh.ball.type != BallType_Core && rh.ball != self) {
                rh.ball.power = 0.0f;
                rh.ball.isBeingDestroyed = YES;
                [rh.ball.node runAction:action_inflateThanDestroy(rh.ball, gameModel)];
            }
        }
    }
    isBeingDestroyed = YES;
    [node runAction:action_destroy(self, gameModel)];
}

@end
