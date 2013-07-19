//
//  LevelDirector.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameModel;

@interface LevelDirector : NSObject<NSCoding> {
    int idx;
    NSMutableArray* logics;
}

- (void)encodeWithCoder:(NSCoder*)aCoder;
- (id)initWithCoder:(NSCoder*)aDecoder;

- (void) execute:(CGFloat)dt gameModel:(GameModel*)aGameModel;
- (BOOL) powerActionRequested:(GameModel*)aGameModel;

@end

@interface StandardLevelDirector : LevelDirector {
}

@end
