//
//  TripopAppDelegate.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "TripopAppDelegate.h"

#import "BackgroundLayer.h"
#import "InfoLayer.h"
#import "MainMenuLayer.h"
#import "LevelDirector.h"
#import "GameModel.h"
#import "common.h"
#import "SimpleAudioEngine.h"
                    
@implementation TripopAppDelegate

@synthesize gameModel;
@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];	
	[window setMultipleTouchEnabled:NO];
	
	// must be called before any othe call to the director
	// WARNING: FastDirector doesn't interact well with UIKit controls
	//	[Director useFastDirector];
	
	// before creating any layer, set the landscape mode
	[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	[[Director sharedDirector] setDisplayFPS:NO];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// create an openGL view inside a window
	[[Director sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	initializeCommon();
    Scene* scene = [Scene node];
    [scene addChild:[BackgroundLayer node]];
    InfoLayer* infoLayer = [InfoLayer node];
    [infoLayer convertToDemoMode];
    [scene addChild:infoLayer];
    [scene addChild:[MainMenuLayer node]];
	[[Director sharedDirector] runWithScene: scene];    
}

- (void)dealloc {
	[[Director sharedDirector] release];
    [gameModel release];
	[window release];
	[super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[Director sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ALERTVIEW_GAME_ENDED) {
        NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults) {
            [standardUserDefaults setBool:NO forKey:@"gameSaved"];
            [standardUserDefaults synchronize];
        }        
        Scene* scene = [Scene node];
        [scene addChild:[BackgroundLayer node]];
        InfoLayer* infoLayer = [InfoLayer node];
        [infoLayer convertToDemoMode];
        [scene addChild:infoLayer];
        [scene addChild:[MainMenuLayer node]];
        TransitionScene* transitionScene = [FadeTransition transitionWithDuration:1.0f scene:scene withColor:ccBLACK];
        [[Director sharedDirector] replaceScene: transitionScene];
        self.gameModel = nil;
    }
    [alertView release];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if (gameModel) {
        gameModel.__isRunning = NO;
        [gameModel unschedule:@selector(step:)];
    }
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* file = [documentsDirectory stringByAppendingPathComponent:@"savedGame.archive"];    
    if (gameModel && !gameModel.gameIsOver) {
        if (![NSKeyedArchiver archiveRootObject:gameModel toFile:file]) {
            NSLog(@"Error in archiving. No archive saved.");
        }
    }
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        if (gameModel && !gameModel.gameIsOver) {
            [standardUserDefaults setBool:YES forKey:@"gameSaved"];
        } else {
            [standardUserDefaults setBool:NO forKey:@"gameSaved"];
        }
        [standardUserDefaults setObject:[NSString stringWithFormat:@"%d", hiscore] forKey:@"hiscore"];
        [standardUserDefaults synchronize];
    }
	[[Director sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) playExplosion {
    [[SimpleAudioEngine sharedEngine] playEffect:@"explosion1.wav"];
}

- (void) playExplosionWithDelay:(ccTime)aDelay {
    [[Director sharedDirector].runningScene runAction:[Sequence actions:
                     [DelayTime actionWithDuration:aDelay],
                     [CallFunc actionWithTarget:self selector:@selector(playExplosion)], nil]];    
}

- (void) playPop {
    [[SimpleAudioEngine sharedEngine] playEffect:@"pop.wav"];
}

- (void) playPopWithDelay:(ccTime)aDelay {
    [[Director sharedDirector].runningScene runAction:[Sequence actions:
                     [DelayTime actionWithDuration:aDelay],
                     [CallFunc actionWithTarget:self selector:@selector(playPop)], nil]];
}

- (void) playElectric {
    [[SimpleAudioEngine sharedEngine] playEffect:@"electricity2.wav"];
}

- (void) playCollapse {
    [[SimpleAudioEngine sharedEngine] playEffect:@"collapse1.wav"];
}

- (void) playConnect {
    [[SimpleAudioEngine sharedEngine] playEffect:@"connect3.wav"];
}

@end
