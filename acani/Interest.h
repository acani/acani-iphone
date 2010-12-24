//
//  Interest.h
//  acani
//
//  Created by Matt Di Pasquale on 12/24/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Resource.h"

@class Profile;

@interface Interest :  Resource  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* profiles;
@property (nonatomic, retain) NSSet* children;
@property (nonatomic, retain) Interest * parent;

+ (Interest *)findByOid:(NSString *)oid;
+ (Interest *)findByOid:(NSString *)oid inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (Interest *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end


@interface Interest (CoreDataGeneratedAccessors)
- (void)addProfilesObject:(Profile *)value;
- (void)removeProfilesObject:(Profile *)value;
- (void)addProfiles:(NSSet *)value;
- (void)removeProfiles:(NSSet *)value;

- (void)addChildrenObject:(Interest *)value;
- (void)removeChildrenObject:(Interest *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

@end

