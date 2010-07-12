@class LoversViewController;

@interface LoversAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LoversViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LoversViewController *viewController;

@end
