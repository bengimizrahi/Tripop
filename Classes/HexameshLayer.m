//
//  HexameshLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HexameshLayer.h"

#import "Ball.h"
#import "Grid.h"
#import "Hexamesh.h"
#import "GameModel.h"
#import "TripopAppDelegate.h"

@interface HexameshLayer(Private)
- (CGPoint) __positionOnLayer:(UITouch*)aTouch;
- (void) __touchMovedWithDelta:(CGFloat)dx;
@end

@implementation HexameshLayer

- (id) initWithGameModel:(GameModel*)aGameModel {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        CGSize s = [[Director sharedDirector] winSize];
        self.position = ccp(s.width/2, s.height/2 + 9.0f);
        self.anchorPoint = ccp(0.0f, 0.0f);
        self.relativeAnchorPoint = YES;
        
        gameModel = aGameModel;
        __x = 0;
        __doubleClickState = DoubleClickState_None;
        lastStoredRotation = self.rotation;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeFloat:lastStoredRotation forKey:@"lastStoredRotation"];
    self.rotation = prevRotation = lastStoredRotation;
    [aCoder encodeObject:gameModel forKey:@"gameModel"];
}

- (id) initWithCoder:(NSCoder*)aDecoder {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        CGSize s = [[Director sharedDirector] winSize];
        self.position = ccp(s.width/2, s.height/2 + 9.0f);
        self.anchorPoint = ccp(0.0f, 0.0f);
        self.relativeAnchorPoint = YES;
        
        gameModel = [aDecoder decodeObjectForKey:@"gameModel"];
        __x = 0;
        __doubleClickState = DoubleClickState_None;
        lastStoredRotation = [aDecoder decodeFloatForKey:@"lastStoredRotation"];
    }
    return self;
}

- (void) updateRotation {
    prevRotation = self.rotation;
    self.rotation = lastStoredRotation;
}

- (CGPoint) __positionOnLayer:(UITouch*)aTouch {
    CGPoint p = [[Director sharedDirector] convertToGL:[aTouch locationInView:[aTouch view]]];
    CGPoint r = ccpSub(p, self.position);
    return r;
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint p = [self __positionOnLayer:touch];
    if (p.y > 150) {
        [gameModel powerActionRequested];
    }
    NSTimeInterval timestamp = [touch timestamp];
    BOOL touchIsTooLate = (timestamp - __lastTouchBeganTimestamp > 0.2) ? YES : NO;
    if (__doubleClickState == DoubleClickState_None) {
        __doubleClickState = DoubleClickState_FirstTouchBegan;
    } else if (__doubleClickState == DoubleClickState_FirstTouchBegan) {
        NSAssert(NO, @"__doubleClickState == DoubleClickState_FirstTouchBegan");
    } else if (__doubleClickState == DoubleClickState_FirstTouchEnded) {
        if (!touchIsTooLate) {
            __doubleClickState = DoubleClickState_SecondTouchBegan;
        } else {
            __doubleClickState = DoubleClickState_FirstTouchBegan;
        }
    } else if (__doubleClickState == DoubleClickState_SecondTouchBegan) {
        NSAssert(NO, @"__doubleClickState == DoubleClickState_SecondTouchBegan");
    }
    __lastTouchBeganTimestamp = timestamp;
    
    __x = p.x;
    __smoothTouch = YES;
    return kEventHandled;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint p = [self __positionOnLayer:touch];
    CGFloat dx = p.x - __x;
    if (__smoothTouch) {
        dx /= 8;
    }
    [self __touchMovedWithDelta:dx];
    __smoothTouch = NO;
    __x = p.x;
    return kEventHandled;
}

- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    NSTimeInterval timestamp = [touch timestamp];
    BOOL touchIsTooLate = (timestamp - __lastTouchBeganTimestamp > 0.2) ? YES : NO;
    if (__doubleClickState == DoubleClickState_None) {
        NSAssert(NO, @"__doubleClickState == DoubleClickState_None");
    } else if (__doubleClickState == DoubleClickState_FirstTouchBegan) {
        if (!touchIsTooLate) {
            __doubleClickState = DoubleClickState_FirstTouchEnded;
        } else {
            __doubleClickState = DoubleClickState_None;
        }
    } else if (__doubleClickState == DoubleClickState_FirstTouchEnded) {
        NSAssert(NO, @"__doubleClickState == DoubleClickState_FirstTouchEnded");
    } else if (__doubleClickState == DoubleClickState_SecondTouchBegan) {
        if (!touchIsTooLate) {
            [gameModel pauseGame];
        }
        __doubleClickState = DoubleClickState_None;   
    }
    __lastTouchBeganTimestamp = timestamp;
    
    return [self ccTouchesMoved:touches withEvent:event];
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    return [self ccTouchesMoved:touches withEvent:event];
}

- (void) __touchMovedWithDelta:(CGFloat)dx {
    lastStoredRotation = lastStoredRotation + dx*TOUCH_SENSITIVITY;
}

@end
