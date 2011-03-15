// 
//  Interest.m
//  acani
//
//  Created by Matt Di Pasquale on 12/24/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "Interest.h"
#import "AppDelegate.h"

#import "Profile.h"

@implementation Interest 

@dynamic name;
@dynamic profiles;
@dynamic children;
@dynamic parent;

+ (Interest *)insertWithDictionary:(NSDictionary *)dictionary
			inManagedObjectContext:(NSManagedObjectContext *)context {
	Interest *interest = \
			(Interest *)[NSEntityDescription insertNewObjectForEntityForName:@"Interest"
													  inManagedObjectContext:context];
	[interest setOid:[dictionary valueForKey:@"_id"]];
	[interest setName:[dictionary valueForKey:@"n"]];

	// As long as parents come before their children, the line below will work.
	[interest setParent:[Interest findByAttribute:@"oid" value:[dictionary valueForKey:@"p"]
									   entityName:@"Interest" inManagedObjectContext:context]];
	return interest;
}

@end
