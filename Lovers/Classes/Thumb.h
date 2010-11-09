//
//  Thumb.h
//  Lovers
//
//  Created by Matt Di Pasquale on 11/8/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class User;

@interface Thumb :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * oid;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) User * user;

@end



