//
//  GameModel.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@class Ball;
@class Hexamesh;
@class Level;
//@class InfoLayer;
@class HexameshLayer;
@class SpaceLayer;

@interface GameModel : Layer {
    NSMutableArray* freeBalls;
    NSMutableArray* attachedBalls;
    NSMutableArray* poppingBalls;
    Hexamesh* hexamesh;
    NSMutableArray* levels;
    Level* currentLevel;

//  InfoLayer* infoLayer;
    SpaceLayer* spaceLayer;
    HexameshLayer* hexameshLayer;

    NSInteger ballsJustDestroyed;
    CGFloat prevRotation;
}

@property (nonatomic, readonly) NSMutableArray* freeBalls;
@property (nonatomic, readonly) NSMutableArray* attachedBalls;
@property (nonatomic, readonly) Hexamesh* hexamesh;
@property (nonatomic, readonly) NSMutableArray* levels;

@property (nonatomic, readonly) SpaceLayer* spaceLayer;
@property (nonatomic, readonly) HexameshLayer* hexameshLayer;
//@property (nonatomic, readonly) InfoLayer* infoLayer;

- (void) startGame;
- (void) step:(CGFloat)dt;

@end
