// 
//  User.m
//  Lovers
//
//  Created by Matt Di Pasquale on 9/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "User.h"

#import "Account.h"
#import "Location.h"

@implementation User 

@dynamic fbId;
@dynamic updated;
@dynamic age;
@dynamic headline;
@dynamic sex;
@dynamic onlineStatus;
@dynamic weight;
@dynamic lastOnline;
@dynamic likes;
@dynamic uid;
@dynamic fbUsername;
@dynamic height;
@dynamic ethnicity;
@dynamic showDistance;
@dynamic location;
@dynamic account;

+ (User *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	[user setUid:[[dictionary valueForKey:@"_id"] valueForKey:@"$oid"]];
	[user setAbout:[dictionary valueForKey:@"a"]];
	[user setShowDistance:[dictionary valueForKey:@"d"]];
	[user setEthnicity:[dictionary valueForKey:@"e"]];
	[user setHeight:[dictionary valueForKey:@"h"]];
	[user setFbId:[dictionary valueForKey:@"i"]];
	Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
	[location setLatitude:[[dictionary valueForKey:@"l"] objectAtIndex:0]];
	[location setLongitude:[[dictionary valueForKey:@"l"] objectAtIndex:1]];
	[user setLocation:location];
	[user setName:[dictionary valueForKey:@"n"]];
	[user setOnlineStatus:[dictionary valueForKey:@"o"]];
	[user setWeight:[dictionary valueForKey:@"p"]];
	[user setHeadline:[dictionary valueForKey:@"q"]];
	[user setLastOnline:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"r"] doubleValue]]];
	[user setSex:[dictionary valueForKey:@"s"]];
	[user setUpdated:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"t"] doubleValue]]];
	[user setFbUsername:[dictionary valueForKey:@"u"]];
	[user setLikes:[dictionary valueForKey:@"v"]];
	[user setAge:[dictionary valueForKey:@"y"]];
	return user;
}

+ (NSDictionary *)encodeKeysInDictionary:(NSDictionary *)dictionary {
	NSDictionary *encoder = [[NSDictionary alloc] initWithObjectsAndKeys:
							 @"a", @"about",
							 @"d", @"showDistance",
							 @"e", @"ethnicity",
							 @"h", @"height",
							 @"n", @"name",
							 @"o", @"onlineStatus", // not yet used
							 @"p", @"weight",
							 @"q", @"headline",
							 @"r", @"lastOnline", // not yet used
							 @"s", @"sex",
							 @"u", @"fbUsername",
							 @"v", @"likes",
							 @"y", @"age", nil];

	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithCapacity:[encoder count]];
	for (id key in dictionary) {
		[tempDict setValue:[dictionary valueForKey:key] forKey:[encoder valueForKey:key]];
	}
	[encoder release];
	NSDictionary *encodedDict = [NSDictionary dictionaryWithDictionary:tempDict];
	[tempDict release];
	return encodedDict;
}

//// How do we convert oid to created_at timestamp?
//// http://stackoverflow.com/questions/3746835/convert-mongodb-bson-objectid-oid-to-generated-time-in-objective-c
//- timeFromBsonOid:(NSString *)oid {
//    time_t out;
//    memcpy(&out, oid, 4);
//    return out;
//}

@end
