//
//  Logic.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameModel;

@interface Level : NSObject {
    BOOL expired;
    NSArray* ballTypes;
    int ballsLeft;
    CGFloat ballSpeed;
    CGFloat createBallInterval;
    CGFloat createBallTimer;
    
    GameModel* gameModel;
}

@property (nonatomic, assign) BOOL expired;
@property (nonatomic, assign) GameModel* gameModel;

- (id) initWithBallTypes:(NSArray*)aBallTypes
                  repeat:(int)aRepeat
               ballSpeed:(CGFloat)aBallSpeed
      createBallInterval:(CGFloat)aCreateBallInterval;

- (void) execute:(CGFloat)dt;
- (NSString*) description;

@end
