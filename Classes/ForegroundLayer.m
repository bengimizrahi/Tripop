//
//  ForegroundLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ForegroundLayer.h"

#import "PowerBar.h"
#import "common.h"
#import "cocos2d.h"

@implementation ForegroundLayer

@synthesize powerBar;

- (id) init {
    if ((self = [super init])) {        
        self.position = ccp(0.0f, 0.0f);
        
        powerBar = [[PowerBar alloc] init];
        powerBar.anchorPoint = ccp(0.0f, 1.0f);
        powerBar.position = ccp(0.0f, 480.0f);
        [self addChild:powerBar];
        
        Sprite* tripop = [Sprite spriteWithFile:@"Tripop2.png"];
        tripop.position = ccp(0.0f, 0.0f);
        tripop.anchorPoint = ccp(0.0f, 0.0f);
        [self addChild:tripop];
    }
    return self;
}

- (void) dealloc {
    [powerBar release];
    [super dealloc];
}

@end
