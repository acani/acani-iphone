#import <CoreLocation/CoreLocation.h>

@interface UsersViewController : UITableViewController {
	
    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	
	CLLocation *location;
	NSMutableArray *users;
	NSInteger columnCount;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSMutableArray *users;
@property (nonatomic, assign) NSInteger columnCount;

- (void)loadUsers;
- (void)reload;
- (void)loadMoreUsers;
	
@end
