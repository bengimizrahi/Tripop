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

typedef enum {
    DoubleClickState_None = 0,
    DoubleClickState_FirstTouchBegan,
    DoubleClickState_FirstTouchEnded,
    DoubleClickState_SecondTouchBegan,
} DoubleClickState;

@interface HexameshLayer : RotatingLayer {
    CGFloat lastStoredRotation;
    
    CGFloat __x;
    BOOL __smoothTouch;
    NSTimeInterval __lastTouchBeganTimestamp;
    DoubleClickState __doubleClickState;
}

- (void) updateRotation;

@end
