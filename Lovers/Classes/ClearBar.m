//
//  ClearBar.m
//  Lovers
//
//  Created by Matt Di Pasquale on 11/2/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "ClearBar.h"


@implementation ClearBar

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.clearsContextBeforeDrawing = NO;
		self.clipsToBounds = NO;
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.translucent = YES;		
	}
	return self;
}

// Override draw rect to avoid background coloring.
- (void)drawRect:(CGRect)rect {
    // do nothing in here
//	CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0f, -1.0f);
}

@end
