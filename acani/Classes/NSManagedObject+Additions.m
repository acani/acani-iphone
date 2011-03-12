#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (acani)

+ (NSManagedObject *)findByAttribute:(NSString *)attribute
							  value:(NSString *)value
						  entityName:(NSString *)entityName
			 inManagedObjectContext:(NSManagedObjectContext *)context {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", attribute, value];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
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

@end
