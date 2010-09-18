//
//  User.h
//  Lovers
//
//  Created by Matt Di Pasquale on 9/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Profile.h"

@class Account;
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
@property (nonatomic, retain) Account * account;

+ insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end



