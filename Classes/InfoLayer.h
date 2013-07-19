//
//  InfoLayer.h
//  Tripop
//
//  Created by Bengi Mizrahi on 9/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

#import <Foundation/Foundation.h>

@class PowerBar;

@interface InfoLayer : Layer {
    PowerBar* powerBar;
    
    BitmapFontAtlas* scoreLabel;
    BitmapFontAtlas* scoreValueLabel;
    BitmapFontAtlas* hiScoreLabel;
    BitmapFontAtlas* hiScoreValueLabel;
}

@property (nonatomic, readonly) PowerBar* powerBar;

@property (nonatomic, readonly) BitmapFontAtlas* scoreLabel;
@property (nonatomic, readonly) BitmapFontAtlas* scoreValueLabel;
@property (nonatomic, readonly) BitmapFontAtlas* hiScoreLabel;
@property (nonatomic, readonly) BitmapFontAtlas* hiScoreValueLabel;

- (void) convertToDemoMode;

@end
