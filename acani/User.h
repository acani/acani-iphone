//
//  User.h
//  acani
//
//  Created by Matt Di Pasquale on 12/24/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Profile.h"

@class Account;

@interface User :  Profile  
{
}

@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * showDistance;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * ethnicity;
@property (nonatomic, retain) NSNumber * showAge;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSNumber * sex;
@property (nonatomic, retain) Account * account;

+ (User *)findByOid:(NSString *)oid;
+ (User *)findByOid:(NSString *)oid inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (User *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (NSDictionary *)encodeKeysInDictionary:(NSDictionary *)dictionary;

- (User *)updateWithDictionary:(NSDictionary *)dictionary;

- (BOOL)hasInterest:(Interest *)anInterest;

@end



