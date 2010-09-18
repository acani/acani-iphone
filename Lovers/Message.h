//
//  Message.h
//  Lovers
//
//  Created by Matt Di Pasquale on 9/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Profile;

@interface Message :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Profile * sender;

@end



