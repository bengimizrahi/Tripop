//
//  MainMenuLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import <Foundation/Foundation.h>

@interface MainMenuLayer : Layer<UIAlertViewDelegate> {

}

- (void) startNewGame;
- (void) resumeGame;
- (void) playGameTapped:(id)sender;
- (void) optionsTapped:(id)sender;
- (void) helpTapped:(id)sender;
- (void) creditsTapped:(id)sender;

@end
