// 
//  User.m
//  Lovers
//
//  Created by Matt Di Pasquale on 11/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "User.h"
#import "Picture.h"
#import "LoversAppDelegate.h"


@implementation User 

@dynamic weight;
@dynamic showDistance;
@dynamic height;
@dynamic ethnicity;
@dynamic showAge;
@dynamic birthday;
@dynamic likes;
@dynamic sex;
@dynamic account;

+ (User *)findByOid:(NSString *)oid {
	LoversAppDelegate *appDelegate = (LoversAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
	return [User findByOid:oid inManagedObjectContext:managedObjectContext];
}

+ (User *)findByOid:(NSString *)oid inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
											  inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"oid == %@", oid];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (fetchedObjects == nil) {
		// TODO: email error to support@acani.com
		// See http://code.google.com/p/skpsmtpmessage/
		NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
		return nil;
	} else if ([fetchedObjects count] > 0) {
		return [fetchedObjects objectAtIndex:0];
	}
	return nil;
}

+ (User *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
	[user setLocation:location];
	Picture *picture = (Picture *)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:managedObjectContext];
	[user setPicture:picture];
	return [user updateWithDictionary:dictionary];
}

- (User *)updateWithDictionary:(NSDictionary *)dictionary {
	[self setOid:[[dictionary valueForKey:@"_id"] valueForKey:@"$oid"]];
	[self setAbout:[dictionary valueForKey:@"a"]];
	[self setWeight:[dictionary valueForKey:@"b"]];
	[self setShowDistance:[dictionary valueForKey:@"d"]];
	[self setEthnicity:[dictionary valueForKey:@"e"]];
	[self setHeight:[dictionary valueForKey:@"h"]];
	[self setFbId:[dictionary valueForKey:@"i"]];
	[[self location] setLatitude:[[dictionary valueForKey:@"l"] objectAtIndex:0]];
	[[self location] setLongitude:[[dictionary valueForKey:@"l"] objectAtIndex:1]];
	[self setName:[dictionary valueForKey:@"n"]];
	[self setOnlineStatus:[dictionary valueForKey:@"o"]];
	[[self picture] setPid:[dictionary valueForKey:@"p"]];
	[self setHeadline:[dictionary valueForKey:@"q"]];
	[self setLastOnline:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"r"] doubleValue]]];
	[self setSex:[dictionary valueForKey:@"s"]];
	[self setUpdated:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"t"] doubleValue]]];
	[self setFbUsername:[dictionary valueForKey:@"u"]];
	[self setLikes:[dictionary valueForKey:@"v"]];
	[self setBirthday:[dictionary valueForKey:@"y"]];
	return self;
}

+ (NSDictionary *)encodeKeysInDictionary:(NSDictionary *)dictionary {
	NSDictionary *encoder = [[NSDictionary alloc] initWithObjectsAndKeys:
							 @"a", @"about",
							 @"b", @"weight",
							 @"d", @"showDistance",
							 @"e", @"ethnicity",
							 @"h", @"height",
							 @"i", @"fbId",
							 @"n", @"name",
							 @"o", @"onlineStatus", // not yet used
							 @"q", @"headline",
							 @"r", @"lastOnline", // not yet used
							 @"s", @"sex",
							 @"u", @"fbUsername",
							 @"v", @"likes",
							 @"y", @"age", nil];
	
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithCapacity:[encoder count]];
	NSLog(@"dicionary: %@", dictionary);
	for (id key in dictionary) {
		[tempDict setValue:[dictionary valueForKey:key] forKey:[encoder valueForKey:key]];
	}
	[encoder release];
	NSDictionary *encodedDict = [NSDictionary dictionaryWithDictionary:tempDict];
	[tempDict release];
	return encodedDict;
}

// How do we convert oid to created_at timestamp? TODO: Test if this works.
// http://stackoverflow.com/questions/3746835/convert-mongodb-bson-objectid-oid-to-generated-time-in-objective-c
- (NSDate *)dateFromBsonOid:(NSString *)oid {
	double timestamp;
	[[NSScanner scannerWithString:[oid substringToIndex:8]] scanHexDouble:&timestamp];
	return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

@end
