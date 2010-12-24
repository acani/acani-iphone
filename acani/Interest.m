// 
//  Interest.m
//  acani
//
//  Created by Matt Di Pasquale on 12/19/10.
//  Copyright 2010 Diamond Dynasties, Inc. All rights reserved.
//

#import "Interest.h"
#import "AppDelegate.h"

#import "Profile.h"

@implementation Interest 

@dynamic name;
@dynamic profiles;
@dynamic children;
@dynamic parent;

+ (Interest *)findByOid:(NSString *)oid {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
	return [Interest findByOid:oid inManagedObjectContext:managedObjectContext];
}

+ (Interest *)findByOid:(NSString *)oid inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Interest" // only difference
											  inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"oid == %@", oid];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (fetchedObjects == nil) {
		// TODO: email error to support@acani.com
		// See http://code.google.com/p/skpsmtpmessage/
		NSLog(@"Fetch sender error %@, %@", error, [error userInfo]);
		return nil;
	} else if ([fetchedObjects count] > 0) {
		return [fetchedObjects objectAtIndex:0];
	}
	return nil;
}

+ (Interest *)insertWithDictionary:(NSDictionary *)dictionary inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
	Interest *interest = (Interest *)[NSEntityDescription insertNewObjectForEntityForName:@"Interest" inManagedObjectContext:managedObjectContext];
	[interest setName:[dictionary valueForKey:@"n"]];
	// As long as parents come before their children, the line below will work.
	[interest setParent:[Interest findByOid:[dictionary valueForKey:@"p"]]];
	return interest;
}

@end
