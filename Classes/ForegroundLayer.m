//
//  ForegroundLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ForegroundLayer.h"

#import "common.h"
#import "cocos2d.h"

@implementation ForegroundLayer

- (id) init {
    if ((self = [super init])) {        
        self.position = ccp(0.0f, 0.0f);
        
        Sprite* foregroundSprite = [Sprite spriteWithFile:@"Tripop.png"];
        foregroundSprite.position = ccp(0.0f, 0.0f);
        foregroundSprite.anchorPoint = ccp(0.0f, 0.0f);
        [self addChild:foregroundSprite];
    }
    return self;
}

@end
