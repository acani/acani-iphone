//
//  Interest.h
//  acani
//
//  Created by Matt Di Pasquale on 12/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Profile;

@interface Interest :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* profiles;
@property (nonatomic, retain) NSSet* children;
@property (nonatomic, retain) NSManagedObject * parent;

+ (Interest *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end


@interface Interest (CoreDataGeneratedAccessors)
- (void)addProfilesObject:(Profile *)value;
- (void)removeProfilesObject:(Profile *)value;
- (void)addProfiles:(NSSet *)value;
- (void)removeProfiles:(NSSet *)value;

- (void)addChildrenObject:(NSManagedObject *)value;
- (void)removeChildrenObject:(NSManagedObject *)value;
- (void)addChildren:(NSSet *)value;
- (void)removeChildren:(NSSet *)value;

@end

