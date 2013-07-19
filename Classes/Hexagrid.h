//
//  Hexagrid.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Ball;
@class Hexagrid;

@interface Hexagrid : NSObject {
    int identifier;
    Ball* ball;
    NSMutableArray* neighbours;
    BOOL dirty;
    int distance;
    CGPoint position;
}

@property (nonatomic, assign) int identifier;
@property (nonatomic, retain) Ball* ball;
@property (nonatomic, retain) NSMutableArray* neighbours;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) CGPoint position;

- (NSArray*) sameColorGroup;

- (NSString*) description;

@end
