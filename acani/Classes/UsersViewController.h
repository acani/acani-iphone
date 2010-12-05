#import <CoreLocation/CoreLocation.h>

@class User;

@interface UsersViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSUInteger columnCount;
	User *myUser;

    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

	CLLocation *location;
	NSMutableData *urlData;
}

@property (nonatomic, retain) User *myUser;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSMutableData *urlData;

- (id)initWithMe:(User *)user;
- (void)logout;
- (void)login;
- (void)goToProfile;
- (void)loadUsers;
- (void)loadMoreUsers;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)cleanUpUsers;

@end
