//
//  TripopAppDelegate.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameModel;

@interface TripopAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
    
    GameModel* gameModel;
}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) GameModel* gameModel;

@end
