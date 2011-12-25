#define HC_SHORTHAND
#import <Cedar-iPhone/SpecHelper.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#import "NSManagedObject+Additions.h"
#import "User.h"

SPEC_BEGIN(NSManagedObjectAdditionsSpec)

describe(@"NSManagedObject+Additions", ^{
	__block NSManagedObjectContext *managedObjectContext;	
	
	beforeEach(^{
		NSManagedObjectModel *managedObjectModel =
        [NSManagedObjectModel mergedModelFromBundles:nil];

//		DLog(@"entities: %@", [managedObjectModel entities]);

		NSPersistentStoreCoordinator *persistentStoreCoordinator =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

		[persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
												 configuration:nil URL:nil options:nil error:NULL];

		managedObjectContext = [[NSManagedObjectContext alloc] init];
		managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;

		[persistentStoreCoordinator release];
	});
	
	afterEach(^{
		[managedObjectContext release];
	});	

    it(@"finds first object by attribute value", ^{
		// Create a user with an arbitrary Facebook user ID.
		NSNumber *fbId = [[NSNumber alloc] initWithInteger:514417];
		[[NSEntityDescription insertNewObjectForEntityForName:@"User"
									  inManagedObjectContext:managedObjectContext] setFbId:fbId];
		[managedObjectContext save:nil];

		NSNumber *fbIdFound = [(User *)[User findByAttribute:@"fbId" value:(id)fbId
												  entityName:@"User"
									  inManagedObjectContext:managedObjectContext] fbId];

		assertThatInteger([fbId integerValue], equalToInteger([fbIdFound integerValue]));

		[fbId release];
    });
});

SPEC_END
