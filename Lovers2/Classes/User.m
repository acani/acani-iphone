//
//  User.m
//  Acani
//
//  Created by Abhinav Sharma on 6/29/10.
//  Copyright 2010 Columbia University. All rights reserved.
//

#import "User.h"
#import "SBJSON.h"
#import "JSON.h"

@implementation User

@synthesize userId;
@synthesize fbId;
@synthesize name;


- (id)initWithJsonDictionary:(NSDictionary*)dictionary
{
	if (self = [super init]) {    
		self.userId    = [dictionary valueForKey:@"id"];
		
		self.fbId      = [[dictionary objectForKey:@"fb_id"] longValue];
		NSLog(@"user fbID %d", self.fbId);
		self.name      = [dictionary objectForKey:@"name"];
		NSLog(@"user fbID %@", self.name);
	}
	return self;
}
/*
+ (NSArray *)findNearest {
    NSURL *url = [NSURL URLWithString:@"file:///Users/Abhinav/code/ALphotoviewer/ALThumbs3/users.js"];
    
    NSError *error = nil;
    
    NSString *jsonString = 
	[NSString stringWithContentsOfURL:url 
							 encoding:NSUTF8StringEncoding 
								error:&error];
    
    NSMutableArray *users = [NSMutableArray array];
    if (jsonString) {
        SBJSON *json = [[SBJSON alloc] init];    
        NSArray *results = [json objectWithString:jsonString error:&error];
        [json release];
        
        for (NSDictionary *dictionary in results) {
            User *user = [[User alloc] initWithDictionary:dictionary];
            [users addObject:user];
            [user release];
        }
    }
    return users;    
}

*/ 

- (void)dealloc 
{
	[userId release];
	[name release];
   	[super dealloc];
}

 
@end
