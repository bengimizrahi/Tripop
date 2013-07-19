//
//  Dynamite.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"
#import "Hexagrid.h"
#import "Dynamite.h"
#import "common.h"
#import "cocos2d.h"

@implementation Dynamite

- (id) initWithInpectLevel:(int)aLevel {
    if ((self = [super initWithType:BallType_Dynamite])) {
        inpectLevel = aLevel;
        [node runAction:[RepeatForever actionWithAction:[RotateBy actionWithDuration:0.25f angle:360]]];
    }
    return self;
}

- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall {    
    Hexagrid* h = aAttachedBall.hexagrid;
    NSArray* rings = [h ringsToLevel:inpectLevel];
    for (int i = 0; i < [rings count]; ++i) {
        NSArray* ring = [rings objectAtIndex:i];
        for (Hexagrid* rh in ring) {
            if (rh.ball.type != BallType_Core && rh.ball != self) {
                rh.ball.power = 0.0f;
                [rh.ball.node runAction:action_inflateThanDestroy(rh.ball)];
            }
        }
    }
    [node runAction:action_destroy(self)];
}

@end
