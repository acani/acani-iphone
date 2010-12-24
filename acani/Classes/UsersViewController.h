#import <CoreLocation/CoreLocation.h>

@class User;
@class Interest;

@interface UsersViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSUInteger columnCount;
	User *myUser;
	Interest *theInterest;

    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;

	CLLocation *location;
	NSMutableData *urlData;
}

@property (nonatomic, retain) User *myUser;
@property (nonatomic, retain) Interest *theInterest;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, retain) NSMutableData *urlData;

- (id)initWithMe:(User *)user interest:(Interest *)interest;
- (void)logout;
- (void)login;
- (void)goToProfile;
- (void)refresh;
- (void)loadMore;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)cleanUpUsers;

@end
