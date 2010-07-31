//
//  CustomURLConnection.h
//  Lovers
//
//  Created by Abhinav Sharma on 7/18/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CustomURLConnection : NSURLConnection {
	NSString *tag;
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag;

@end