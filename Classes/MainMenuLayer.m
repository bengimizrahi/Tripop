//
//  MainMenuLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"

#import "SpaceLayer.h"
#import "HexameshLayer.h"
#import "BackgroundLayer.h"
#import "InfoLayer.h"
#import "ScoresLayer.h"
#import "GameModel.h"
#import "TripopAppDelegate.h"
#import "common.h"

@implementation MainMenuLayer

- (id) init {
    if ((self = [super init])) {
		BitmapFontAtlas* label;
        label = [BitmapFontAtlas bitmapFontAtlasWithString:@"PLAY GAME" fntFile:@"silkworm.fnt"];
		MenuItemLabel* newGameLabel = [MenuItemLabel itemWithLabel:label target:self selector:@selector(playGameTapped:)];
        
        label = [BitmapFontAtlas bitmapFontAtlasWithString:@"OPTIONS" fntFile:@"silkworm.fnt"];
        MenuItemLabel* optionsLabel = [MenuItemLabel itemWithLabel:label target:self selector:@selector(optionsTapped:)];
        
        label = [BitmapFontAtlas bitmapFontAtlasWithString:@"HELP" fntFile:@"silkworm.fnt"];
        MenuItemLabel* helpLabel = [MenuItemLabel itemWithLabel:label target:self selector:@selector(helpTapped:)];

        label = [BitmapFontAtlas bitmapFontAtlasWithString:@"CREDITS" fntFile:@"silkworm.fnt"];
        MenuItemLabel* creditsLabel = [MenuItemLabel itemWithLabel:label target:self selector:@selector(creditsTapped:)];
        
        Menu* menu = [Menu menuWithItems:newGameLabel, optionsLabel, helpLabel, creditsLabel, nil];
        [menu alignItemsVertically];
        
        menu.position = ccpAdd(menu.position, ccp(0.0f, 35.0f));
        [self addChild:menu];
    }
    return self;
}

- (void) startNewGame {
    Scene* scene = [Scene node];
    [scene addChild:[BackgroundLayer node]];
    GameModel* gameModel = [GameModel node];
    TripopAppDelegate* delegate = (TripopAppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.gameModel = gameModel;
    [scene addChild:gameModel];
    [scene addChild:gameModel.spaceLayer];
    [scene addChild:gameModel.hexameshLayer];
    [scene addChild:gameModel.infoLayer];
    [scene addChild:gameModel.scoresLayer];
    TransitionScene* transitionScene = [FadeTransition transitionWithDuration:1.0f scene:scene withColor:ccBLACK];
	[[Director sharedDirector] replaceScene:transitionScene];
    [gameModel startGame];
}

- (void) resumeGame {
    Scene* scene = [Scene node];
    [scene addChild:[BackgroundLayer node]];
    TripopAppDelegate* delegate = (TripopAppDelegate*)[UIApplication sharedApplication].delegate;
    if (!delegate.gameModel) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* file = [documentsDirectory stringByAppendingPathComponent:@"savedGame.archive"];
        GameModel* gameModel = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
        NSAssert(gameModel, @"GameModel could not be unarchived");
        delegate.gameModel = gameModel;
    } else {
        NSLog(@"delegate.gameModel != nil, use it in the this scene.");
    }
    [scene addChild:delegate.gameModel];
    [scene addChild:delegate.gameModel.spaceLayer];
    [scene addChild:delegate.gameModel.hexameshLayer];
    [scene addChild:delegate.gameModel.infoLayer];
    [scene addChild:delegate.gameModel.scoresLayer];
    TransitionScene* transitionScene = [FadeTransition transitionWithDuration:1.0f scene:scene withColor:ccBLACK];
    [[Director sharedDirector] replaceScene:transitionScene];
    [delegate.gameModel resumeGame];
} 

- (void) playGameTapped:(id)sender {
    TripopAppDelegate* delegate = (TripopAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString* str = [[NSUserDefaults standardUserDefaults] objectForKey:@"gameSaved"];
    if ((str && [str isEqualToString:@"YES"]) || delegate.gameModel) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Would you like to start a new game or continue from the last game?" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"New", @"Continue", nil];
        [alertView show];
        return;
    }
    [self startNewGame];
}

- (void) optionsTapped:(id)sender {
    
}

- (void) helpTapped:(id)sender {
    
}

- (void) creditsTapped:(id)sender {
    
}

// ------------ UIAlertViewDelegate -----------------

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"New Game selected, calling [self startNewGame]");
        [self startNewGame];
    } else if (buttonIndex == 1) {
        NSLog(@"Resume Game selected, calling [self resumeGame]");
        [self resumeGame];
    }
    [alertView release];
}

@end
