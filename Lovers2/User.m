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

+ insertWithDictionary:(NSDictionary *)dictionary withDateFormatter:(NSDateFormatter *)dateFormatter inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	User *user = (User *)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:managedObjectContext];
	[user setAbout:[dictionary valueForKey:@"about"]];
	[user setAge:[dictionary valueForKey:@"age"]];
	[user setCreated:[dateFormatter dateFromString:[dictionary valueForKey:@"created"]]];
	[user setEthnicity:[dictionary valueForKey:@"ethnic"]];
	[user setFbid:[dictionary valueForKey:@"fbid"]];
	[user setFbLink:[dictionary valueForKey:@"fb_link"]];
	[user setHeadline:[dictionary valueForKey:@"head"]];
	[user setHeight:[dictionary valueForKey:@"height"]];
	[user setLastOnline:[dateFormatter dateFromString:[dictionary valueForKey:@"last_on"]]];
	[user setLikes:[dictionary valueForKey:@"likes"]];
	Location *location = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:managedObjectContext];
	[location setLatitude:[[dictionary valueForKey:@"loc"] objectAtIndex:0]];
	[location setLongitude:[[dictionary valueForKey:@"loc"] objectAtIndex:1]];
	[user setLocation:location];
	[user setName:[dictionary valueForKey:@"name"]];
	[user setOnlineStatus:[dictionary valueForKey:@"on_stat"]];
	[user setSex:[dictionary valueForKey:@"sex"]];
	[user setShowDistance:[dictionary valueForKey:@"sdis"]];
	[user setUpdated:[dateFormatter dateFromString:[dictionary valueForKey:@"updated"]]];
	[user setUid:[[dictionary valueForKey:@"_id"] valueForKey:@"$oid"]];
	[user setWeight:[dictionary valueForKey:@"weight"]];
	return user;
}

@end
