//
//  Lightning.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Lightning.h"

#import "Hexagrid.h"
#import "common.h"
#import "cocos2d.h"
#import "GameModel.h"

@implementation Lightning

- (id) initWithGameModel:(GameModel*)aGameModel {
    if ((self = [super initWithType:BallType_Lightning gameModel:aGameModel])) {
        [self resumeActions];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [super encodeWithCoder:aCoder];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    [super initWithCoder:aDecoder];
    [self resumeActions];
    return self;
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
    [gameModel playElectric];
    isBeingDestroyed = YES;
    [node runAction:action_destroy(self, gameModel)];
    NSArray* pathToCore = [aAttachedBall randomPathToCore];
    for (Ball* b in pathToCore) {
        b.power = 0.0f;
        b.isBeingDestroyed = YES;
        [b.node runAction:action_whiteBlinkThanDestroy(b, gameModel)];
    }
}

@end
