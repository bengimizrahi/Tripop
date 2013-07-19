//
//  HelpLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TapAndMenuLayer.h"

#import "BackgroundLayer.h"
#import "InfoLayer.h"
#import "MainMenuLayer.h"

@implementation TapAndMenuLayer

- (id) initWithImage:(NSString*)aFile {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        Sprite* sprite = [Sprite spriteWithFile:aFile];
        sprite.anchorPoint = ccp(0.0f, 0.0f);
        [self addChild:sprite];
    }
    return self;
}

- (BOOL) ccTouchesBegan:(UITouch*)touch withEvent:(UIEvent*)event {
    Scene* scene = [Scene node];
    [scene addChild:[BackgroundLayer node]];
    InfoLayer* infoLayer = [InfoLayer node];
    [infoLayer convertToDemoMode];
    [scene addChild:infoLayer];
    [scene addChild:[MainMenuLayer node]];
    TransitionScene* transitionScene = [FadeTransition transitionWithDuration:1.0f scene:scene];
	[[Director sharedDirector] replaceScene:transitionScene];
    return kEventHandled;
}

@end
