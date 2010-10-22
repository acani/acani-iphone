#import <CoreLocation/CoreLocation.h>

@class User;

@interface UsersViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSInteger columnCount;

	User *me;

    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

	CLLocation *location;
	NSMutableData *userData;
}

@property (nonatomic, assign) NSInteger columnCount;

@property (nonatomic, retain) User *me;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSMutableData *userData;

- (void)logout;
- (void)login;
- (void)goToProfile;

//- (void)loadUsers;
//- (void)reload;
//- (void)loadMoreUsers;
	
@end
