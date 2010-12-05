//
//  Message.h
//  acani
//
//  Created by Matt Di Pasquale on 11/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Profile;

@interface Message :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSSet* receivers;
@property (nonatomic, retain) Profile * sender;

@end


@interface Message (CoreDataGeneratedAccessors)
- (void)addReceiversObject:(Profile *)value;
- (void)removeReceiversObject:(Profile *)value;
- (void)addReceivers:(NSSet *)value;
- (void)removeReceivers:(NSSet *)value;

@end

