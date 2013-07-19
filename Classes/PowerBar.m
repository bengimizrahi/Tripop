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
    // 65 --- 310
    CGPoint p = self.position;
	glLineWidth(5.0f);
        
    CGPoint vertices[4];
    vertices[0] = ccp(65, p.y + 10);
    vertices[1] = ccp(100, p.y + 10);
    vertices[2] = ccp(310, p.y + 10);
    vertices[3] = ccp(310 - (2.46 * (100 - power)), p.y + 10);
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    CGFloat colors[12] = {0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f};
    glColorPointer(4, GL_FLOAT, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);
    
	glDrawArrays(GL_LINE_STRIP, 0, 3);
	
    glDisableClientState(GL_COLOR_ARRAY);
    glColor4f(0.0f, 0.0f, 0.0f, 1.0f);
    
    glDrawArrays(GL_LINES, 2, 2);
    glDisableClientState(GL_VERTEX_ARRAY);
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

- (void) addPower:(CGFloat)aPower {
    self.power = MIN(100, self.power + aPower);
}

- (void) dealloc {
    [powerDrawing release];
    [super dealloc];
}

- (CGFloat) power {
    return powerDrawing.power;
}

- (void) setPower:(CGFloat)aPower {
    powerDrawing.power = aPower;
}

@end
