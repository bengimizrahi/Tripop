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
@class HexameshLayer;
@class SpaceLayer;
@class InfoLayer;
@class ScoresLayer;

@interface GameModel : Layer {
    NSMutableArray* freeBalls;
    NSMutableArray* attachedBalls;
    NSMutableArray* poppingBalls;
    Hexamesh* hexamesh;
    NSMutableArray* levels;
    Level* currentLevel;

    SpaceLayer* spaceLayer;
    HexameshLayer* hexameshLayer;
    InfoLayer* infoLayer;
    ScoresLayer* scoresLayer;

    NSMutableArray* ballsJustDestroyed;
    CGFloat prevRotation;
    
    int score;
    int hiScore;
}

@property (nonatomic, readonly) NSMutableArray* freeBalls;
@property (nonatomic, readonly) NSMutableArray* attachedBalls;
@property (nonatomic, readonly) Hexamesh* hexamesh;
@property (nonatomic, readonly) Level* currentLevel;

@property (nonatomic, readonly) SpaceLayer* spaceLayer;
@property (nonatomic, readonly) HexameshLayer* hexameshLayer;
@property (nonatomic, readonly) InfoLayer* infoLayer;
@property (nonatomic, readonly) ScoresLayer* scoresLayer;

- (void) startGame;
- (void) pauseGame;
- (void) resumeGame;
- (void) step:(CGFloat)dt;
- (void) powerActionRequested;
- (void) addPointsToScore:(int)aPoints;

@end
