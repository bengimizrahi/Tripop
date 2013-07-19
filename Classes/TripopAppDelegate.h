//
//  TripopAppDelegate.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "cocos2d.h"

#import <UIKit/UIKit.h>

@class GameModel;

@interface TripopAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate> {
	UIWindow *window;
    
    GameModel* gameModel;
}

- (void) playExplosion;
- (void) playExplosionWithDelay:(ccTime)aDelay;
- (void) playPop;
- (void) playPopWithDelay:(ccTime)aDelay;
- (void) playElectric;
- (void) playCollapse;
- (void) playConnect;

@property (nonatomic, retain) UIWindow* window;

@property (nonatomic, retain) GameModel* gameModel;

@end
