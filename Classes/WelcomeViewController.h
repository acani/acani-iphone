@interface WelcomeViewController : UIViewController {
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void)connectWithFB;

@end
