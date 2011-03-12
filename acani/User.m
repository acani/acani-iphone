// 
//  User.m
//  acani
//
//  Created by Matt Di Pasquale on 12/24/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "User.h"
#import "Location.h"
#import "Picture.h"
#import "AppDelegate.h"

#import "Account.h"

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
	[self setPhone:[dictionary valueForKey:@"j"]];
	//	[self setRelStat:[dictionary valueForKey:@"k"]];
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
	//	[self setWebsite:[dictionary valueForKey:@"w"]]; // TODO: add to user model
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd"];
	[self setBirthday:[df dateFromString:[dictionary valueForKey:@"y"]]];
	[df release];
	[self setShowAge:[dictionary valueForKey:@"z"]];
	return self;
}

// Encodes user data before posting to server.
+ (NSDictionary *)encodeKeysInDictionary:(NSDictionary *)dictionary {
	NSDictionary *encoder = [[NSDictionary alloc] initWithObjectsAndKeys:
							 @"a", @"about",
							 @"b", @"weight",
							 @"d", @"showDistance",
							 @"e", @"ethnicity",
							 @"h", @"height",
							 // fbId won't be changed.
							 @"j", @"phone", // not yet used
							 @"k", @"relStat", // not yet used
							 @"n", @"name",
							 @"o", @"onlineStatus", // not yet used
							 // picId we get from the server's response.
							 @"q", @"headline",
							 @"r", @"lastOnline", // not yet used
							 @"s", @"sex",
							 // updated we get from the server's response.
							 @"u", @"fbUsername",
							 @"v", @"likes",
							 @"y", @"birthday",
							 @"z", @"showBirthday", nil];
	
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

- (BOOL)hasInterest:(Interest *)anInterest {
	return [[self interests] containsObject:anInterest];
}

@end
