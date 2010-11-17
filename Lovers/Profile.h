//
//  Profile.h
//  Lovers
//
//  Created by Matt Di Pasquale on 11/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Location;
@class Message;
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
@property (nonatomic, retain) Location * location;
@property (nonatomic, retain) NSSet* receivedMessages;

@end


@interface Profile (CoreDataGeneratedAccessors)
- (void)addSentMessagesObject:(Message *)value;
- (void)removeSentMessagesObject:(Message *)value;
- (void)addSentMessages:(NSSet *)value;
- (void)removeSentMessages:(NSSet *)value;

- (void)addReceivedMessagesObject:(Message *)value;
- (void)removeReceivedMessagesObject:(Message *)value;
- (void)addReceivedMessages:(NSSet *)value;
- (void)removeReceivedMessages:(NSSet *)value;

@end

