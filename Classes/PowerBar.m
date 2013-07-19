//
//  PowerBar.m
//  Tripop
//
//  Created by Bengi Mizrahi on 10/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PowerBar.h"

@implementation PowerDrawing

@synthesize power;

- (void) draw {
    // 62 --- 310
    CGPoint p = self.position;
    glDisable(GL_LINE_SMOOTH);
	glLineWidth(5.0f);
	glColor4ub(255, 0, 0, 50);
	drawLine(ccp(65, p.y + 10), ccp(65 + 2.44 * power, p.y + 10));
}

@end

@implementation PowerBar

@dynamic power;

- (id) init {
    if ((self = [super initWithFile:@"PowerBar.png"])) {
        powerDrawing = [[PowerDrawing alloc] init];
        [self addChild:powerDrawing];
    }
    return self;
}

- (void) dealloc {
    [powerDrawing release];
    [super dealloc];
}

- (void) setPower:(CGFloat)aPower {
    powerDrawing.power = aPower;
}

- (CGFloat) power {
    return powerDrawing.power;
}

@end
