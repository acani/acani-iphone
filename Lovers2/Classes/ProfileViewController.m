#import "LoversAppDelegate.h"
#import "ProfileViewController.h"

#define MAINLABEL	((UILabel *)self.navigationItem.titleView)

@implementation ProfileViewController

- (ProfileViewController *) init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	self.title = @"Edit Profile";
	return self;	
}

- (void)edit:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)back:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)saveProfile:(id)sender {
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)loadView {
	[super loadView];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Lovers"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(back:)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];

	// set up the table's header view based on our UIView 'myHeaderView' outlet
	profileHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 86.0f)];
	profileHeader.clearsContextBeforeDrawing = NO;
	profileHeader.backgroundColor = [UIColor clearColor];

	UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 18.0f, 62.0f, 62.0f)];
	avatar.image = [UIImage imageNamed:@"BlankAvatar.png"];
	[profileHeader addSubview:avatar];
	[avatar release];

	UILabel *profileName = [[UILabel alloc] initWithFrame:CGRectMake(96.0f, 39.0f, 212.0f, 21.0f)];
	profileName.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
	profileName.adjustsFontSizeToFitWidth = YES;
	profileName.minimumFontSize = 10.0f;
	profileName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	profileName.text = @"Matt Di Pasquale";
	profileName.backgroundColor = [UIColor clearColor];

	profileHeader.clearsContextBeforeDrawing = NO;	

	profileHeader.backgroundColor = [UIColor clearColor];
	[profileHeader addSubview:profileName];
	[profileName release];

	self.tableView.tableHeaderView = profileHeader;	// note this will override UITableView's 'sectionHeaderHeight' property
	
	aboutInput = [[UITextView alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, 50.0f)];
	
	//aboutInput.clearsContextBeforeDrawing = NO;
	aboutInput.font = [UIFont systemFontOfSize:14.0];
	//aboutInput.dataDetectorTypes = UIDataDetectorTypeAll;
	aboutInput.backgroundColor = [UIColor grayColor];
	aboutInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
	aboutInput.delegate = self;	

	int height = 22.0f;
	profileFields = [[NSArray alloc] initWithObjects:@"About",@"Age",@"Height",@"Weight",@"Ethnicity",@"Facebook",nil];
	profileValues =	[[NSArray alloc] initWithObjects:
					 aboutInput,
					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],nil];
					 
	 profileFields1 = [[NSArray alloc] initWithObjects:@"Distance",@"Age Filter",nil];
	 profileValues1 = [[NSArray alloc] initWithObjects:
					   [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
					   [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)], nil];

//self.navigationItem.backBarButtonItem =
//	[[[UIBarButtonItem alloc] initWithTitle:@"Acani" style:UIBarButtonItemStyleBordered
//									 target:self action:nil] autorelease];
//

//[self performSelector:@selector(displayViews) withObject:nil afterDelay:0.0f];

//	CGRect pvcf = [[UIScreen mainScreen] applicationFrame];
//	pvcf = CGRectMake(pvcf.origin.x, pvcf.origin.y+44.0f, pvcf.size.width, pvcf.size.height-44.0f);
//
//	self.tableView.frame = pvcf;
//
//	UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
//	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Profile"];
////	UIBarButtonItem *saveBtn = 
//	navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile:)];
//	[navBar pushNavigationItem:navItem animated:NO];
//	[self.view.superview addSubview:navBar];
//
////	// This didn't work, but is it possible to use the HomeViewController's
////	// navigationController's navBar instead of making a new one?
////    [contentView addSubview:self.parentViewController.navigationController.navigationBar];
//
////	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(40.0f, 100.0f, 90.0f, 44.0f)];
////	[button setTitle:@"Save2" forState:UIControlStateNormal];
////	[button addTarget:self action:@selector(saveProfile:) forControlEvents:UIControlEventTouchUpInside];
////	[contentView addSubview:button];
//
//	[navItem.leftBarButtonItem release];
//	[navItem release];
//	[navBar release];
}


#pragma mark -
#pragma mark Initialization

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if ((self = [super initWithStyle:style])) {
 }
 return self;
 }
 */


#pragma mark -
#pragma mark View lifecycle


//- (void)loadView {
//	[super loadView];
//	[self performSelector:@selector(displayViews) withObject:nil afterDelay:3.0f];

//	NSLog(@"parentView: %@", self.parentViewController.view);
//	NSLog(@"parentView: %@", self.parentViewController.view.subviews);
//	[self.parentViewController.view removeFromSuperview];
//  // maybe put a willChangeWindow?
//	[self.view addSubview:self.parentViewController.view];

//	self.navigationItem.titleView = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)] autorelease];
//	[MAINLABEL setBackgroundColor:[UIColor clearColor]];
//	[MAINLABEL setTextColor:[UIColor whiteColor]];
//	[MAINLABEL setTextAlignment:UITextAlignmentCenter];
//	[MAINLABEL setText:@"Profile"];
//}

//- (void)viewDidLoad {
//	[super viewDidLoad];
//
//	// Uncomment the following line to preserve selection between presentations.
////	self.clearsSelectionOnViewWillAppear = NO;
//
//	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//	 self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Basic Information:";
	} else {
		return @"Filter Option:";
	}
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 6;
	} else { 
		return 2;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		if (indexPath.section == 0) {
			cell.textLabel.text = [profileFields objectAtIndex:indexPath.row];
			if (indexPath.row == 0) {
				[cell.contentView addSubview:aboutInput];
				[aboutInput release];
			} else {
				[cell.contentView addSubview:[profileValues objectAtIndex:indexPath.row]];
			}
		} else if (indexPath.section == 1) {
			cell.textLabel.text = [profileFields1 objectAtIndex:indexPath.row];
			[cell.contentView addSubview:[profileValues1 objectAtIndex:indexPath.row]];
		}
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	if (indexPath.section == 0 && indexPath.row == 0) {
		return 60.0f;
	} else {
		return 30.0f;
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	return YES;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	editIndexPath = indexPath;
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 1:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"1",@"2", @"3", nil];
				break;
			case 2:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"6''",@"6''1", @"6''2", nil];
				break;
			case 3:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"150",@"160", @"170", nil];
				break;
			case 4:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"Chris",@"None", @"", nil];
				break;
			case 5:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"Distance",@"Age Filter", @"w", nil];
				break;
				
			default:
				break;
		}
	} else if (indexPath.section == 1) {
		switch (indexPath.row) {
			case 0:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"10",@"20", @"30", nil];
				break;
				
			case 1:
				pickerViewArray = [[NSArray alloc] initWithObjects:@"15",@"16", @"1", nil];
				break;
				
			default:
				break;
		}
	}

	aac = [[UIActionSheet alloc] initWithTitle:nil
														 delegate:self
												cancelButtonTitle:nil
										   destructiveButtonTitle:nil
												otherButtonTitles:nil];
		
		[aac setActionSheetStyle:UIActionSheetStyleDefault];
		
		
		pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 10, 200, 320)];
		pickerView.showsSelectionIndicator = YES;
		pickerView.delegate = self;
		
		[aac addSubview:pickerView];
		[pickerView release];
		
//		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
//		closeButton.momentary = YES; 
//		closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
//		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
//		closeButton.tintColor = [UIColor blackColor];
//		[closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
//		[aac addSubview:closeButton];
//		[closeButton release];
//		
//		[aac showInView:self.view];
//		
//		[aac setBounds:CGRectMake(0, 0, 320, 485)];
		
		
		pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		pickerToolbar.barStyle = UIBarStyleBlackOpaque;
		[pickerToolbar sizeToFit];
		
		NSMutableArray *barItems = [[NSMutableArray alloc] init];
		
		UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
		[barItems addObject:flexSpace];
	
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissActionSheet:)];
   [barItems addObject:doneBtn];
		
	[pickerToolbar setItems:barItems animated:YES];
		
	    [aac addSubview:pickerToolbar];
		[aac showInView:self.view];
		[aac setBounds:CGRectMake(0,0,320, 320)];
}

-(BOOL)dismissActionSheet:(id)sender {
	[aac dismissWithClickedButtonIndex:0 animated:YES];
	[pickerView release];
	[pickerToolbar release];
	return YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [pickerViewArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [pickerViewArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSLog(@"Selected Color: %@. Index of selected color: %i", [pickerViewArray objectAtIndex:row], row);
	NSLog(@"editIndexPath: %@", editIndexPath);
	
	if (editIndexPath.section == 0) {
		[[profileValues objectAtIndex:editIndexPath.row] setText:[pickerViewArray objectAtIndex:row]];
	} else {
		[[profileValues1 objectAtIndex:editIndexPath.row] setText:[pickerViewArray objectAtIndex:row]];
	}
}

-(void) DatePickerDoneClick{
	
	//[actionSheet dismissWithClickedButtonIndex: animated:NO];
	 NSLog(@"2");
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	profileHeader = nil;
	[super viewDidUnload];
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}

- (void)dealloc {
	[profileHeader release];
    [super dealloc];
}

@end
