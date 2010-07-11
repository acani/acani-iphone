//
//  message.h
//  Bubbles
//
//  Created by Rsg on 7/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface message : NSObject {
	NSString* message;
	time_t* timestamp;
	uint32_t* sender_id;
	uint32_t receiver_id;

}

@property (nonatomic, retain) NSString* message;
@property (nonatomic, assign) time_t timestamp;
@property (nonatomic, assign) uint32_t sender_id;
@property (nonatomic, assign) uint32_t receiver_id;

@end
