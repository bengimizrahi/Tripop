//
//  ScoresLayer.m
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ScoresLayer.h"

#import "PowerBar.h"
#import "common.h"
#import "cocos2d.h"

@implementation ScoresLayer

- (id) init {
    if ((self = [super init])) {        
        CGSize s = [[Director sharedDirector] winSize];
        self.position = ccp(s.width/2, s.height/2 + 45.0f);
        self.anchorPoint = ccp(0.0f, 0.0f);
        self.relativeAnchorPoint = YES;
    }
    return self;
}

- (void) __removeLabel:(Label*)aLabel {
    [self removeChild:aLabel cleanup:YES];
}

- (void) addPoints:(int)aPoints animateAtPosition:(CGPoint)aPosition duration:(ccTime)aDuration scaleBy:(CGFloat)aScaleBy {
    BitmapFontAtlas* label = [BitmapFontAtlas bitmapFontAtlasWithString:[NSString stringWithFormat:@"%d", aPoints] fntFile:@"silkworm.fnt"];
    label.position = aPosition;
    label.scale = 0.25f;
    [label runAction:[Sequence actions:[Spawn actions:[ScaleBy actionWithDuration:aDuration scale:aScaleBy],
                                                      [MoveBy actionWithDuration:aDuration position:ccp(0,20)], nil],
                                       [CallFuncN actionWithTarget:self selector:@selector(__removeLabel:)], nil]];
    [self addChild:label];
}

@end
