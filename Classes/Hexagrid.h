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

@interface Hexagrid : NSObject<NSCoding> {
    int identifier;
    Ball* ball;
    NSMutableArray* neighbours;
    BOOL dirty;
    int distance;
    CGPoint position;
    
    int __ringDistance;
}

@property (nonatomic, assign) int identifier;
@property (nonatomic, retain) Ball* ball;
@property (nonatomic, retain) NSMutableArray* neighbours;
@property (nonatomic, assign) BOOL dirty;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) CGPoint position;

@property (nonatomic, assign) int __ringDistance;

- (void)encodeWithCoder:(NSCoder*)aCoder;
- (id)initWithCoder:(NSCoder*)aDecoder;

- (NSArray*) sameColorGroup;
- (NSArray*) ringsToLevel:(int)aLevel;
- (BOOL) isNull;
- (NSString*) description;

@end
