//
//  ForegroundLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InfoLayer.h"

#import "PowerBar.h"
#import "common.h"
#import "cocos2d.h"

@implementation InfoLayer

@synthesize powerBar;
@synthesize scoreLabel, scoreValueLabel, hiScoreLabel, hiScoreValueLabel;

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

        scoreLabel = [[BitmapFontAtlas bitmapFontAtlasWithString:@"SCORE:" fntFile:@"silkworm.fnt"] retain];
        scoreLabel.position = ccp(0.0f, 3.0f);
        scoreLabel.anchorPoint = ccp(0.0f, 0.0f);
        scoreLabel.scale = 0.25f;
        [self addChild:scoreLabel];
        scoreValueLabel = [[BitmapFontAtlas bitmapFontAtlasWithString:@"00000000" fntFile:@"silkworm.fnt"] retain];
        scoreValueLabel.position = ccp(50.0f, 3.0f);
        scoreValueLabel.anchorPoint = ccp(0.0f, 0.0f);
        scoreValueLabel.scale = 0.25f;
        [self addChild:scoreValueLabel];
        hiScoreLabel = [[BitmapFontAtlas bitmapFontAtlasWithString:@"HI-SCORE:" fntFile:@"silkworm.fnt"] retain];
        hiScoreLabel.position = ccp(176.0f, 3.0f);
        hiScoreLabel.anchorPoint = ccp(0.0f, 0.0f);
        hiScoreLabel.scale = 0.25f;
        [self addChild:hiScoreLabel];
        hiScoreValueLabel = [[BitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%d", hiscore] fntFile:@"silkworm.fnt"] retain];
        hiScoreValueLabel.position = ccp(250.0f, 3.0f);
        hiScoreValueLabel.anchorPoint = ccp(0.0f, 0.0f);
        hiScoreValueLabel.scale = 0.25f;
        [self addChild:hiScoreValueLabel];
    }
    return self;
}

- (void) dealloc {
    [powerBar release];
    
    [scoreLabel release];
    [scoreValueLabel release];
    [hiScoreLabel release];
    [hiScoreValueLabel release];
    [super dealloc];
}

- (void) convertToDemoMode {
    [self removeChild:scoreLabel cleanup:YES];
    [self removeChild:scoreValueLabel cleanup:YES];
}
@end
