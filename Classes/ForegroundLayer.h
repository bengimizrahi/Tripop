//
//  ForegroundLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import <Foundation/Foundation.h>

@class PowerBar;

@interface ForegroundLayer : Layer {
    PowerBar* powerBar;
}

@property (nonatomic, readonly) PowerBar* powerBar;

- (id) init;

@end