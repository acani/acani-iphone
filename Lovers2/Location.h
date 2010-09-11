//
//  Location.h
//  Lovers
//
//  Created by Matt Di Pasquale on 9/11/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Location :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSManagedObject * user;

@end



