//
//  CustomURLConnection.m
//  Lovers
//
//  Created by Abhinav Sharma on 7/18/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import "CustomURLConnection.h"


@implementation CustomURLConnection

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag {
	self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
	
	if (self) {
		self.tag = tag;
	}
	return self;
}

- (void)dealloc {
	[tag release];
	[super dealloc];
}

@end