//
//  Profile.h
//  acani
//
//  Created by Matt Di Pasquale on 12/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Picture;

@interface Profile :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * fbId;
@property (nonatomic, retain) NSDate * lastOnline;
@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSNumber * onlineStatus;
@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * fbUsername;
@property (nonatomic, retain) NSString * oid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Picture * picture;
@property (nonatomic, retain) NSSet* sentMessages;
@property (nonatomic, retain) NSManagedObject * location;
@property (nonatomic, retain) NSSet* receivedMessages;
@property (nonatomic, retain) NSSet* interests;

@end


@interface Profile (CoreDataGeneratedAccessors)
- (void)addSentMessagesObject:(NSManagedObject *)value;
- (void)removeSentMessagesObject:(NSManagedObject *)value;
- (void)addSentMessages:(NSSet *)value;
- (void)removeSentMessages:(NSSet *)value;

- (void)addReceivedMessagesObject:(NSManagedObject *)value;
- (void)removeReceivedMessagesObject:(NSManagedObject *)value;
- (void)addReceivedMessages:(NSSet *)value;
- (void)removeReceivedMessages:(NSSet *)value;

- (void)addInterestsObject:(NSManagedObject *)value;
- (void)removeInterestsObject:(NSManagedObject *)value;
- (void)addInterests:(NSSet *)value;
- (void)removeInterests:(NSSet *)value;

@end

