//
//  Dynamite.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"
#import <Foundation/Foundation.h>

@interface Dynamite : Ball {
    int inpectLevel;
}

- (id) initWithInpectLevel:(int)aLevel gameModel:(GameModel*)aGameModel;
- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall;

@end
