//
//  Account.h
//  acani
//
//  Created by Matt Di Pasquale on 12/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Account :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSManagedObject * user;

@end



