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

@implementation Lightning

- (id) init {
    if ((self = [super initWithType:BallType_Lightning])) {
        [node runAction:[RepeatForever actionWithAction:[RotateBy actionWithDuration:0.25f angle:360]]];
    }
    return self;
}

- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall {
    [node runAction:action_destroy(self)];
    NSArray* pathToCore = [aAttachedBall randomPathToCore];
    for (Ball* b in pathToCore) {
        b.power = 0.0f;
        [b.node runAction:action_whiteBlinkThanDestroy(b)];
    }
}

@end
