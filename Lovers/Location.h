//
//  Location.h
//  Lovers
//
//  Created by Matt Di Pasquale on 10/31/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@class User;

@interface Location :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) User * user;

@end



