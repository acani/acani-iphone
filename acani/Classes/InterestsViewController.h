@class User;
@class Interest;

@interface InterestsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	User *myUser;
	Interest *theInterest;
	
    NSManagedObjectContext *managedObjectContext;
	NSFetchedResultsController *fetchedResultsController;
	
	NSMutableData *urlData;
}

@property (nonatomic, retain) User *myUser;
@property (nonatomic, retain) Interest *theInterest;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) NSMutableData *urlData;

- (id)initWithMe:(User *)user interest:(Interest *)interest;
- (void)logout;
- (void)login;
- (void)goToProfile;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
