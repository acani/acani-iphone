#import "User.h"
#import "Location.h"

@implementation User 

@dynamic fbLink;
@dynamic uid;
@dynamic updated;
@dynamic age;
@dynamic headline;
@dynamic sex;
@dynamic onlineStatus;
@dynamic weight;
@dynamic lastOnline;
@dynamic likes;
@dynamic height;
@dynamic fbid;
@dynamic created;
@dynamic ethnicity;
@dynamic showDistance;
@dynamic location;
@dynamic account;

+ insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	[user setAbout:[dictionary valueForKey:@"about"]];
	[user setAge:[dictionary valueForKey:@"age"]];
	[user setCreated:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"created"] doubleValue]]];
	[user setEthnicity:[dictionary valueForKey:@"ethnic"]];
	[user setFbid:[dictionary valueForKey:@"fbid"]];
	[user setFbLink:[dictionary valueForKey:@"fblink"]];
	[user setHeadline:[dictionary valueForKey:@"head"]];
	[user setHeight:[dictionary valueForKey:@"height"]];
	[user setLastOnline:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"laston"] doubleValue]]];
	[user setLikes:[dictionary valueForKey:@"likes"]];
	Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
	[location setLatitude:[[dictionary valueForKey:@"loc"] objectAtIndex:0]];
	[location setLongitude:[[dictionary valueForKey:@"loc"] objectAtIndex:1]];
	[user setLocation:location];
	[user setName:[dictionary valueForKey:@"name"]];
	[user setOnlineStatus:[dictionary valueForKey:@"onstat"]];
	[user setSex:[dictionary valueForKey:@"sex"]];
	[user setShowDistance:[dictionary valueForKey:@"sdist"]];
	[user setUpdated:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"updated"] doubleValue]]];
	[user setUid:[[dictionary valueForKey:@"_id"] valueForKey:@"$oid"]];
	[user setWeight:[dictionary valueForKey:@"weight"]];
	return user;
}

@end
