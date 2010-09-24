//
//  User.h
//  Lovers
//
//  Created by Matt Di Pasquale on 9/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Profile.h"

@class Account;
@class Location;

@interface User :  Profile  
{
}

@property (nonatomic, retain) NSNumber * fbId;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) NSNumber * onlineStatus;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSDate * lastOnline;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * fbUsername;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * ethnicity;
@property (nonatomic, retain) NSNumber * showDistance;
@property (nonatomic, retain) Location * location;
@property (nonatomic, retain) Account * account;

+ (User *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSDictionary *)encodeKeysInDictionary:(NSDictionary *)dictionary;

@end
