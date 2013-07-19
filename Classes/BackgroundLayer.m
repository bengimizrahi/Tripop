//
//  BackgroundLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BackgroundLayer.h"

#import "common.h"
#import "cocos2d.h"

@implementation BackgroundLayer

- (id) init {
    if ((self = [super init])) {        
        self.position = ccp(0.0f, 0.0f);
        
        Sprite* backgroundSprite = [Sprite spriteWithFile:@"Space.png"];
        backgroundSprite.position = ccp(0.0f, 90.0f);
        backgroundSprite.anchorPoint = ccp(0.0f, 0.0f);
        [self addChild:backgroundSprite];
    }
    return self;
}

@end
