//
//  OptionsLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import <Foundation/Foundation.h>

@class MenuItemLabel;

@interface OptionsLayer : Layer {
    MenuItemLabel* toggleSoundLabel;
    Menu* menu;
}

@end
