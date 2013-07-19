//
//  TripopAppDelegate.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "TripopAppDelegate.h"

//#import "InfoLayer.h"
#import "ForegroundLayer.h"
#import "HexameshLayer.h"
#import "SpaceLayer.h"
#import "GameModel.h"
#import "BackgroundLayer.h"
#import "common.h"
#import "cocos2d.h"
                    
@implementation TripopAppDelegate

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
	[[Director sharedDirector] setDisplayFPS:YES];
	
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
    GameModel* gameModel = [GameModel node];
    [scene addChild:gameModel];
    [scene addChild:gameModel.spaceLayer];
    [scene addChild:gameModel.hexameshLayer];
    [scene addChild:[ForegroundLayer node]];
    //  [scene addChild:gameModel.infoLayer];
    
    [gameModel startGame];
	[[Director sharedDirector] runWithScene: scene];
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

- (void)applicationWillTerminate:(UIApplication *)application {
	[[Director sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[Director sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[Director sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
