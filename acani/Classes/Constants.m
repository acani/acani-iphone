#import "Constants.h"

//void myShowAlert(int line, char *functname, id formatstring,...) {
//	va_list arglist;
//	if (!formatstring) return;
//	va_start(arglist, formatstring);
//	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
//	va_end(arglist);
//
//    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
//	[av show];
//}

//void displayRefreshButton(UIViewController controller, NSString buttonTitle, SEL buttonSelector) {
//	// Create a toolbar to have two buttons on the right.
//	// http://osmorphis.blogspot.com/2009/05/multiple-buttons-on-navigation-bar.html
//	UIToolbar *tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 103.0f, 44.01f)]; // 44.01f shifts up by 1px
//	tools.clearsContextBeforeDrawing = NO;
//	tools.clipsToBounds = NO;
//	tools.tintColor = [UIColor colorWithWhite:0.305f alpha:0.0f]; // eye estimate. TODO: make perfect.
//	tools.barStyle = -1; // clear background
//	NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:3];
//
//	// Create a standard refresh button.
//	UIBarButtonItem *bi = [[UIBarButtonItem alloc]
//						   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:controller action:@selector(loadUsers)];
//	[buttons addObject:bi];
//	[bi release];
//
//	// Create a spacer.
//	bi = [[UIBarButtonItem alloc]
//		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//	bi.width = 12.0f;
//	[buttons addObject:bi];
//	[bi release];
//
//	// Add profile button.
//	bi = BAR_BUTTON(buttonTitle, buttonSelector);
//	bi.style = UIBarButtonItemStyleBordered;
//	[buttons addObject:bi];
//	[bi release];
//
//	// Add buttons to toolbar and toolbar to nav bar.
//	[tools setItems:buttons animated:NO];
//	[buttons release];
//	UIBarButtonItem *twoButtons = [[UIBarButtonItem alloc] initWithCustomView:tools];
//	[tools release];
//	controller.navigationItem.rightBarButtonItem = twoButtons;
//	[twoButtons release];
//}