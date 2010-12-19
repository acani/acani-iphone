// 
//  Interest.m
//  acani
//
//  Created by Matt Di Pasquale on 12/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "Interest.h"

#import "Profile.h"

@implementation Interest 

@dynamic name;
@dynamic profiles;
@dynamic children;
@dynamic parent;

+ (Interest *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	Interest *interest = (Interest *)[NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:managedObjectContext];
	[interest setName:[dictionary valueForKey:@"n"]];
	return interest;
}

@end
