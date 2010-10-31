#import <CoreLocation/CoreLocation.h>

@class User;

@interface UsersViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSInteger columnCount;

	User *myUser;

    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

	CLLocation *location;
	NSMutableData *userData;
}

@property (nonatomic, assign) NSInteger columnCount;

@property (nonatomic, retain) User *myUser;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSMutableData *userData;

- (id)initWithMe:(User *)user;
- (void)logout;
- (void)login;
- (void)goToProfile;
- (void)loadUsers;
- (void)loadMoreUsers;
	
@end
