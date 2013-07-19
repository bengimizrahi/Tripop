//
//  HexameshLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "common.h"

#import <Foundation/Foundation.h>

@class GameModel;

@interface HexameshLayer : RotatingLayer {
    CGFloat lastStoredRotation;
    
    CGFloat __x;
    BOOL __smoothTouch;
}

@property (nonatomic, assign) GameModel* gameModel;

- (id) init;

- (void) updateRotation;

@end
