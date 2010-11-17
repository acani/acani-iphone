//
//  Picture.h
//  Lovers
//
//  Created by Matt Di Pasquale on 11/17/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Profile;

@interface Picture :  NSManagedObject  
{
}

@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSString * pid;
@property (nonatomic, retain) Profile * profile;

@end



