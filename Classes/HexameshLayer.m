//
//  HexameshLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HexameshLayer.h"

#import "Ball.h"
#import "Hexagrid.h"
#import "Hexamesh.h"
#import "GameModel.h"

@interface HexameshLayer(Private)
- (void) __touchMovedWithDelta:(CGFloat)dx;
@end

@implementation HexameshLayer

@dynamic gameModel;

- (id) init {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        CGSize s = [[Director sharedDirector] winSize];
        self.position = ccp(s.width/2, s.height/2 + 45.0f);
        self.anchorPoint = ccp(0.0f, 0.0f);
        self.relativeAnchorPoint = YES;
        
        __x = 0;
        lastStoredRotation = self.rotation;
    }
    return self;
}

- (void) updateRotation {
    prevRotation = self.rotation;
    self.rotation = lastStoredRotation;
}

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:[touch view]];
    __x = p.x;
    __smoothTouch = YES;
    return kEventHandled;
}

- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint p = [touch locationInView:[touch view]];
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
    return [self ccTouchesMoved:touches withEvent:event];
}

- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    return [self ccTouchesMoved:touches withEvent:event];
}

- (void) __touchMovedWithDelta:(CGFloat)dx {
    lastStoredRotation = lastStoredRotation + 180.0f/GAME_AREA_RADIUS*dx*TOUCH_SENSITIVITY;
}

- (GameModel*) gameModel {
    return nil;
}

- (void) setGameModel:(GameModel*)aGameModel {
    [self addChild:aGameModel.hexamesh.center.ball.node];
}

@end
