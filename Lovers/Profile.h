//
//  Profile.h
//  Lovers
//
//  Created by Matt Di Pasquale on 9/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Message;

@interface Profile :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * about;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* sentMessages;

@end


@interface Profile (CoreDataGeneratedAccessors)
- (void)addSentMessagesObject:(Message *)value;
- (void)removeSentMessagesObject:(Message *)value;
- (void)addSentMessages:(NSSet *)value;
- (void)removeSentMessages:(NSSet *)value;

@end

