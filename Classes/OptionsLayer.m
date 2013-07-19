//
//  OptionsLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OptionsLayer.h"

#import "BackgroundLayer.h"
#import "InfoLayer.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"

@implementation OptionsLayer

- (id) init {
    if ((self = [super init])) {
        BitmapFontAtlas* label;
        NSString* str;
        if (![SimpleAudioEngine sharedEngine].muted) {
            str = @"SOUNDS:ON";
        } else {
            str = @"SOUNDS:OFF";
        }
		label = [BitmapFontAtlas bitmapFontAtlasWithString:str fntFile:@"silkworm.fnt"];
		toggleSoundLabel = [MenuItemLabel itemWithLabel:label target:self selector:@selector(optionsTapped:)];
        
        label = [BitmapFontAtlas bitmapFontAtlasWithString:@"BACK" fntFile:@"silkworm.fnt"];
		MenuItemLabel* backLabel = [MenuItemLabel itemWithLabel:label target:self selector:@selector(backTapped:)];
        
        menu = [Menu menuWithItems:toggleSoundLabel, backLabel, nil];
        [menu alignItemsVerticallyWithPadding:25.0f];

        menu.position = ccpAdd(menu.position, ccp(0.0f, 35.0f));
        [self addChild:menu];        
    }
    return self;
}

- (void) optionsTapped:(id)sender {
    [SimpleAudioEngine sharedEngine].muted = ![SimpleAudioEngine sharedEngine].muted;
    NSString* str;
    if (![SimpleAudioEngine sharedEngine].muted) {
        str = @"SOUNDS:ON";
    } else {
        str = @"SOUNDS:OFF";
    }
    [toggleSoundLabel.label setString:str];
    toggleSoundLabel.anchorPoint = ccp(0.5f, 0.5f);
    [menu alignItemsVerticallyWithPadding:25.0f];
}

- (void) backTapped:(id)sender {
    Scene* scene = [Scene node];
    [scene addChild:[BackgroundLayer node]];
    InfoLayer* infoLayer = [InfoLayer node];
    [infoLayer convertToDemoMode];
    [scene addChild:infoLayer];
    [scene addChild:[MainMenuLayer node]];
    TransitionScene* transitionScene = [FadeTransition transitionWithDuration:1.0f scene:scene];
	[[Director sharedDirector] replaceScene:transitionScene];
}

@end
