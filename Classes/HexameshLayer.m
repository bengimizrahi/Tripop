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
#import "common.h"
#import "cocos2d.h"

@implementation HexameshLayer

@dynamic gameModel;

- (id) init {
    if ((self = [super init])) {        
        CGSize s = [[Director sharedDirector] winSize];
        self.position = ccp(s.width/2, s.height/2);
    }
    return self;
}

- (GameModel*) gameModel {
    return nil;
}

- (void) setGameModel:(GameModel*)aGameModel {
    [self addChild:aGameModel.hexamesh.center.ball.sprite];
}

@end
