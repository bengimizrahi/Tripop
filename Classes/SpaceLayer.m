//
//  GameLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpaceLayer.h"

#import "common.h"
#import "cocos2d.h"

@implementation SpaceLayer

- (id) init {
    if ((self = [super init])) {        
        CGSize s = [[Director sharedDirector] winSize];
        self.position = ccp(s.width/2, s.height/2 + 45.0f);
    }
    return self;
}

@end
