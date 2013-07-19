//
//  Ball.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Ball.h"

#import "BallMoveStrategy.h"
#import "Hexagrid.h"
#import "common.h"
#import "cocos2d.h"

@implementation Ball

@synthesize identifier, sprite, type, moveStrategy, hexagrid, goingToPop;
@dynamic position;

- (id) initWithType:(BallType)aType {
    if ((self = [super init])) {
        static NSString* imageFiles[] = {@"Core.png", @"RedBall.png", @"GreenBall.png", @"BlueBall.png", @"YellowBall.png"};
        type = aType;
        sprite = [[Sprite alloc] initWithFile:imageFiles[aType]];
        goingToPop = NO;
    }
    return self;
}

- (void) dealloc {
    [sprite release];
    [moveStrategy release];
    
    [super dealloc];
}

- (void) moveByDeltaTime:(CGFloat)dt {
    [moveStrategy moveByDeltaTime:dt];
}

- (CGPoint) position {
    return sprite.position;
}

- (void) setPosition:(CGPoint)pos {
    sprite.position = pos;
}

- (NSString*) description {
    NSString* dstr = @"";
    if (hexagrid && hexagrid.dirty) {
        dstr = @"/D";
    }
    CGPoint pos = sprite.position;
    if (hexagrid) {
        return [NSString stringWithFormat:@"<B%d:(~%d,~%d)-H%s%@-T%d>", identifier, (int)pos.x, (int)pos.y, hexagrid.identifier, dstr, type];
    } else {
        return [NSString stringWithFormat:@"<B%d:(~%d,~%d)----T%d>", identifier, (int)pos.x, (int)pos.y, dstr, type];
    }
}

@end
