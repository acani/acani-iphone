#import <CoreData/CoreData.h>
#import "Profile.h"

@class Location;

@interface User :  Profile  
{
}

@property (nonatomic, retain) NSString * fbLink;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * onlineStatus;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSDate * lastOnline;
@property (nonatomic, retain) NSString * likes;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * fbid;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * ethnicity;
@property (nonatomic, retain) NSNumber * showDistance;
@property (nonatomic, retain) Location * location;
@property (nonatomic, retain) NSManagedObject * account;

+ insertWithDictionary:(NSDictionary *)dictionary withDateFormatter:(NSDateFormatter *)dateFormatter inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end



