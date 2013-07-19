//
//  Lightning.h
//  Tripop
//
//  Created by Bengi Mizrahi on 10/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Ball.h"

@interface Lightning : Ball {
    
}

- (void) applyActionsAfterConnectingTo:(Ball*)aAttachedBall;

@end
