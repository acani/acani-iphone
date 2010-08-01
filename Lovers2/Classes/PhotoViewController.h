@interface PhotoViewController : UIViewController {
	UIView * overlay;
}

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)moveOverlay:(id)sender;
- (void)goToChat:(id)sender;

@end
