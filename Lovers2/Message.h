//
//  Message.h
//  Lovers
//
//  Created by Matt Di Pasquale on 9/11/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Message :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * channel;
@property (nonatomic, retain) NSNumber * timestamp;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSManagedObject * sender;

@end



