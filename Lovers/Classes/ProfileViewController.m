#import "ProfileViewController.h"
#import "LoversAppDelegate.h"

#define MAINLABEL ((UILabel *)self.navigationItem.titleView)

#define ABOUT_ROW 0
#define SEX_ROW 1
#define AGE_ROW 2
#define HEIGHT_ROW 3
#define WEIGHT_ROW 4
#define ETHNICITY_ROW 5

#define VALUE_TAG 121
#define TEXT_VIEW_TAG 122
#define TEXT_FIELD_TAG 123
#define FILTER_TAG 124


@implementation ProfileViewController

@synthesize me;

- (id)initWithMe:(User *)user {
	if (!(self = [super init])) return self;
	me = user;
	self.title = @"Edit Profile";
	return self;
}

- (void)cancel:(id)sender {
	NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	[managedObjectContext refreshObject:me mergeChanges:NO]; // get rid of changes
	[self dismissModalViewControllerAnimated:YES];
}

- (void)saveProfile:(id)sender {
	[me setShowDistance:[NSNumber numberWithBool:[(UISwitch *)[[[self.tableView cellForRowAtIndexPath:
	  [NSIndexPath indexPathForRow:0 inSection:1]] contentView] viewWithTag:FILTER_TAG] isOn]]];

	NSDate *now = [[NSDate alloc] init];
	[me setUpdated:now];
	[now release];

	NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	NSError *error;
	if (![managedObjectContext save:&error]) {
		// Handle the error. What's the best way to handle this?
		NSLog(@"Error saving profile: %@", error);
	}

	// Send a PUT request to: /{uid}
	// See sample in sample-profile-put-request.txt

	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)loadView {
	[super loadView];

	self.wantsFullScreenLayout = YES;

	// I'm not sure how to initialize the default tableView as grouped, so create our own:
	UITableView *groupedTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStyleGrouped];
	groupedTable.delegate = self;
	groupedTable.dataSource = self;
	self.view = groupedTable;
	[groupedTable release];

//	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Cancel"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];

	saveButton = [[UIBarButtonItem alloc] 
				  initWithTitle:@"Save"
				  style:UIBarButtonItemStyleBordered
				  target:self 
				  action:@selector(saveProfile:)];
	self.navigationItem.rightBarButtonItem = saveButton;

	doneButton = [[UIBarButtonItem alloc] 
				  initWithTitle:@"Done"
				  style:UIBarButtonItemStyleBordered
				  target:self 
				  action:@selector(donePickingValue:)];	
	
	textDone = [[UIBarButtonItem alloc] 
				  initWithTitle:@"Done"
				  style:UIBarButtonItemStyleBordered
				  target:self 
				  action:@selector(doneEditingText:)];
//	profileContent = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 244.0f) style:UITableViewStyleGrouped];
//	profileContent = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
//	profileContent.clearsContextBeforeDrawing = NO;
//	profileContent.delegate = self;
//	profileContent.dataSource = self;
//	profileContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;	

	// set up the table's header view
	profileHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 86.0f)];
	profileHeader.clearsContextBeforeDrawing = NO;
	profileHeader.backgroundColor = [UIColor clearColor];

	//UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(20.0f, 18.0f, 62.0f, 62.0f)];
	//avatar.image = [UIImage imageNamed:@"BlankAvatar.png"];
	avatarImg = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:CGRectMake(20.0f, 18.0f, 62, 62)];
	[avatarImg addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[avatarImg setBackgroundImage:[UIImage imageNamed:@"BlankAvatar.png"] forState:UIControlStateNormal];
	//[avatar addSubview:avatarImg];
	//[profileHeader addSubview:avatar];
	[profileHeader addSubview:avatarImg];
	//[avatar release];
	
	profileName = [[UITextField alloc] initWithFrame:CGRectMake(96.0f, 39.0f, 212.0f, 21.0f)];
	
	//UILabel *profileName = [[UILabel alloc] initWithFrame:CGRectMake(96.0f, 39.0f, 212.0f, 21.0f)];
	profileName.clearsContextBeforeDrawing = NO;
	profileName.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0f];
	profileName.adjustsFontSizeToFitWidth = YES;
	profileName.minimumFontSize = 10.0f;
	//profileName.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	profileName.delegate = self;
	profileName.text = [me name];
	profileName.backgroundColor = [UIColor clearColor];
	[profileHeader addSubview:profileName];
	[profileName release];

	self.tableView.tableHeaderView = profileHeader;	// note this overrides UITableView's 'sectionHeaderHeight' property

	// set up the table's header view
	UIView *profileFooter = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 60.0f)];
	profileFooter.clearsContextBeforeDrawing = NO;
	profileFooter.backgroundColor = [UIColor clearColor];
	
	UIButton *clearChatsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	clearChatsButton.frame = CGRectMake(9.0f, 0.0f, 302.0f, 48.0f);
	clearChatsButton.clearsContextBeforeDrawing = NO;
	clearChatsButton.backgroundColor = [UIColor clearColor];
	[clearChatsButton setTitle:@"Clear All Chats" forState:UIControlStateNormal];
	[clearChatsButton addTarget:self action:@selector(clearChats:) forControlEvents:UIControlEventTouchUpInside];
	[profileFooter addSubview:clearChatsButton];

	self.tableView.tableFooterView = profileFooter;

//	[self.view addSubview:profileContent];
//	[profileContent release];

//	valueSelect = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200.0f, 320.0f, 220.0f)];
	valueSelect = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200.0f, 320.0f, 0.0f)];
	valueSelect.clearsContextBeforeDrawing = NO;
	valueSelect.showsSelectionIndicator = YES;
	valueSelect.delegate = self;

//	int height = 22.0f;
	profileFields = [[NSArray alloc] initWithObjects:
					 [[NSArray alloc] initWithObjects:@"About", @"Sex", @"Age", @"Height", @"Weight", @"Ethnicity", @"Facebook", nil],
					 [[NSArray alloc] initWithObjects:@"Show Distance", @"Sex Filter", @"Age Filter", nil], nil];

	// This should be sqlite or something persistent
	profileValues = [[NSArray alloc] initWithObjects:
					 [[NSArray alloc] initWithObjects:@"Optional", @"Optional", @"Optional", @"Optional", @"Optional", @"Optional", @"Optional", nil],
					 [[NSArray alloc] initWithObjects:@"Show", @"Both", @"All ages", nil], nil];
	
	pickerOptions = [[NSArray alloc] initWithObjects:
					 [[NSArray alloc] initWithObjects: // section: 0
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"Do Not Show", @"Female", @"Male", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"Do Not Show",
						// Instead of making these long arrays, we can just put in a switch statement
						// for age & weight (perhaps even height) that translates the current row to an
						// age or weight string. We could even give an age/weight offset, so that
						// instead of starting them at 1, we could start them at a higher number.
						@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
						@"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
						@"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
						@"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
						@"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
						@"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59",
						@"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69",
						@"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79",
						@"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89",
						@"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99",
						@"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109",
						@"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119",
						@"120", @"121", @"122", @"123", @"124", @"125", @"126", @"127", @"128", @"129",
						@"130", @"131", @"132", @"123", @"124", @"125", @"126", @"127", @"128", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"Do Not Show", @"5 feet", @"6 feet", @"7 feet", nil],
					   [[NSArray alloc] initWithObjects:@"0 inches", @"1 inches", @"2 inches", @"3 inches", @"4 inches", @"5 inches", @"6 inches", @"7 inches", @"8 inches", @"9 inches", @"10 inches", @"11 inches", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"Do Not Show",
						@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",
						@"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
						@"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
						@"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
						@"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
						@"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59",
						@"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69",
						@"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79",
						@"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89",
						@"90", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99",						
						@"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109",
						@"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119",
						@"120", @"121", @"122", @"123", @"124", @"125", @"126", @"127", @"128", @"129",
						@"130", @"131", @"132", @"133", @"134", @"135", @"136", @"137", @"138", @"139",
						@"140", @"141", @"142", @"143", @"144", @"145", @"146", @"147", @"148", @"149",
						@"150", @"151", @"152", @"153", @"154", @"155", @"156", @"157", @"158", @"159",
						@"160", @"161", @"162", @"163", @"164", @"165", @"166", @"167", @"168", @"169",
						@"170", @"171", @"172", @"173", @"174", @"175", @"176", @"177", @"178", @"179",
						@"180", @"181", @"182", @"183", @"184", @"185", @"186", @"187", @"188", @"189",
						@"190", @"191", @"192", @"193", @"194", @"195", @"196", @"197", @"198", @"199",
						@"200", @"201", @"202", @"203", @"204", @"205", @"206", @"207", @"208", @"209",
						@"210", @"211", @"212", @"213", @"214", @"215", @"216", @"217", @"218", @"219",
						@"220", @"221", @"222", @"223", @"224", @"225", @"226", @"227", @"228", @"229",
						@"230", @"231", @"232", @"233", @"234", @"235", @"236", @"237", @"238", @"239",
						@"240", @"241", @"242", @"243", @"244", @"245", @"246", @"247", @"248", @"249",
						@"250", @"251", @"252", @"253", @"254", @"255", @"256", @"257", @"258", @"259",
						@"260", @"261", @"262", @"263", @"264", @"265", @"266", @"267", @"268", @"269",
						@"270", @"271", @"272", @"273", @"274", @"275", @"276", @"277", @"278", @"279",
						@"280", @"281", @"282", @"283", @"284", @"285", @"286", @"287", @"288", @"289",
						@"290", @"291", @"292", @"293", @"294", @"295", @"296", @"297", @"298", @"299",
						@"300", @"301", @"302", @"303", @"304", @"305", @"306", @"307", @"308", @"309",
						@"310", @"311", @"312", @"313", @"314", @"315", @"316", @"317", @"318", @"319",
						@"320", @"321", @"322", @"323", @"324", @"325", @"326", @"327", @"328", @"329",
						@"330", @"331", @"332", @"333", @"334", @"335", @"336", @"337", @"338", @"339",
						@"340", @"341", @"342", @"343", @"344", @"345", @"346", @"347", @"348", @"349",
						@"350", @"351", @"352", @"353", @"354", @"355", @"356", @"357", @"358", @"359",
						@"360", @"361", @"362", @"363", @"364", @"365", @"366", @"367", @"368", @"369",
						@"370", @"371", @"372", @"373", @"374", @"375", @"376", @"377", @"378", @"379",
						@"380", @"381", @"382", @"383", @"384", @"385", @"386", @"387", @"388", @"389",
						@"390", @"391", @"392", @"393", @"394", @"395", @"396", @"397", @"398", @"399",
						@"400", nil], nil],					  
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"Do Not Show", @"Asian", @"Black", @"Latino", @"Middle Eastern", @"Mixed", @"Native American", @"White", @"Other", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"", nil], nil], nil],
					 [[NSArray alloc] initWithObjects:  // section: 1
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"Both", @"Women only", @"Men only", nil], nil],
					  [[NSArray alloc] initWithObjects:
					   [[NSArray alloc] initWithObjects:@"No min", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", @"120", @"121", @"122", nil],
					   [[NSArray alloc] initWithObjects:@"No max", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"100", @"101", @"102", @"103", @"104", @"105", @"106", @"107", @"108", @"109", @"110", @"111", @"112", @"113", @"114", @"115", @"116", @"117", @"118", @"119", @"120", @"121", @"122", nil], nil], nil], nil];

	components = [[pickerOptions objectAtIndex:0] objectAtIndex:1];

//	NSLog(@"pickerOptions: %@", pickerOptions);
	NSLog(@"pickerOptions obj: %@", [[[pickerOptions objectAtIndex:0] objectAtIndex:1] objectAtIndex:0]);
//	NSLog(@"self.view.window.subviews: %@", self.view.window.subviews);	
//	NSLog(@"self.view.subviews: %@", self.view.subviews);	
//	NSLog(@"self.view.window: %@", self.view.window);

//	// More views than you could dream of! 
//	printf("\nAll window subviews:\n");
//	NSLog(@"self.view.window: %@", allApplicationViews());

	// Listen for keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
-(void)imageButtonClicked:(id)sender {
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", nil];
	[action showInView:self.view];
}


#pragma mark Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
		NSLog(@"Take Photo");
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:picker animated:YES];
	} else if (buttonIndex == 0) {
		NSLog(@"Choose Photo");
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentModalViewController:picker animated:YES];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	[picker dismissModalViewControllerAnimated:YES];
	[avatarImg setBackgroundImage:image forState:UIControlStateNormal];
	//userImageView.contentMode = UIViewContentModeScaleAspectFit;
}

// Fix with show UIPicker first. Then, uncomment.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// // Return YES for supported orientations
// return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}


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
    return [profileFields count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[profileFields objectAtIndex:section] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *fieldText = [[profileFields objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	NSString *valueText = [[profileValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	static NSString *CellID;
	UITableViewCell *cell;

	if (indexPath.section == 0 && indexPath.row == 0) { // About textView Cell
		CellID = @"TextView";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			aboutInput = [[UITextView alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, 50.0f)];
			//	aboutInput.scrollEnabled = NO;
			aboutInput.clearsContextBeforeDrawing = NO;
			aboutInput.font = [UIFont systemFontOfSize:14.0];
			//	aboutInput.dataDetectorTypes = UIDataDetectorTypeAll;
			aboutInput.backgroundColor = [UIColor grayColor];
			aboutInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
			aboutInput.delegate = self;			
			aboutInput.tag = TEXT_VIEW_TAG;
			[cell.contentView addSubview:aboutInput];
			[aboutInput release];
		}
		aboutInput.text = [me about];
	} else if (indexPath.section == 0 && indexPath.row == 6) { // Facebook textField Cell
		CellID = @"TextField";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			valueInput = [[UITextField alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, 30.0f)];
			valueInput.clearsContextBeforeDrawing = NO;
			valueInput.font = [UIFont systemFontOfSize:14.0];
			valueInput.backgroundColor = [UIColor lightGrayColor];
			valueInput.delegate = self;			
			valueInput.tag = TEXT_FIELD_TAG;
			[cell.contentView addSubview:valueInput];
			[valueInput release];
		}
		valueInput.text = [me fbUsername];

	} else if (indexPath.section == 1 && indexPath.row == 0) { // Distance Filter Cell
		CellID = @"Switch";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UISwitch *filter = [[UISwitch alloc] initWithFrame:CGRectMake(195.0f, (tableView.rowHeight - 27.0f)/2, 95.0f, 27.0f)];
			filter.on = [[me showDistance] boolValue];
			filter.tag = FILTER_TAG;
			[cell.contentView addSubview:filter];
			[filter release];
		}
	} else if (indexPath.section == 0) { // Section 0 cells
		CellID = @"Default2";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;
//			int height = 22.0f;
//			value = [[profileValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//			[cell.contentView addSubview:[[profileValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
//			[cell sendSubviewToBack:cell.textLabel];
		}

		NSArray *Sexes = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] Sexes];
		NSArray *Ethnicities = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] Ethnicities];

		NSNumber *valueNum = [[NSNumber alloc] initWithInt:0];
		switch (indexPath.row) {
			case SEX_ROW:
				// If I try to set cell.detailTextLabel directly here, I get readonly error.
				valueNum = [me sex];
				valueText = [Sexes objectAtIndex:[valueNum intValue]];
				break;
			case AGE_ROW:
				valueNum = [me age];
				valueText = [valueNum stringValue];
				break;
			case HEIGHT_ROW: // TODO: convert height to inches & feet if in USA
				valueNum = [me height];
				valueText = [NSString stringWithFormat:@"%@ cm", [me height]];
				break;
			case WEIGHT_ROW: // TODO: convert weight to kilos if not in USA
				valueNum = [me weight];
				valueText = [NSString stringWithFormat:@"%@ lbs", [me weight]];
				break;
			case ETHNICITY_ROW:
				valueNum = [me ethnicity];
				valueText = [Ethnicities objectAtIndex:[[me ethnicity] intValue]];
				break;
			default:
				break;
		}
		
		if ([valueNum intValue] == 0) {
			valueText = @"Optional";
		}

		cell.detailTextLabel.text = valueText;
	} else { // Section 1 cells
		CellID = @"Default1";
		cell = [tableView dequeueReusableCellWithIdentifier:CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		}
		cell.detailTextLabel.text = valueText;
	}
//	else {
//		value = (UILabel *)[cell.contentView viewWithTag:VALUE_TAG];
//		aboutInput = (UITextView *)[cell.contentView viewWithTag:TEXT_VIEW_TAG];		
//	}
	cell.textLabel.text = fieldText;

	NSLog(@"cell.textLabel: %@", cell.textLabel);
	NSLog(@"cell.detailTextLabel: %@", cell.detailTextLabel);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {  
	if (indexPath.section == 0 && indexPath.row == 0) {
		return 60.0f;
	} else {
		return tableView.rowHeight;
	}
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	textView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 3.0f, 0.0f);
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
	if (valueSelect.superview != nil) {
		[self donePickingValue:self];
	}
	self.navigationItem.rightBarButtonItem = textDone;
}

// Expand textview on keyboard dismissal
- (void)keyboardWillHide:(NSNotification *)notification {
	self.navigationItem.rightBarButtonItem = saveButton;
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
	// check if our date picker is already on screen
	if (valueSelect.superview == nil &&
		!(indexPath.section == 0 && indexPath.row == 0) &&
		!(indexPath.section == 0 && indexPath.row == 6) &&
		!(indexPath.section == 1 && indexPath.row == 0)) {

		[self doneEditingText:self];

		[[[UIApplication sharedApplication] keyWindow] addSubview:valueSelect];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		CGSize pickerSize = [valueSelect sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height);
		valueSelect.frame = startRect;
		
		// compute the end frame
		CGRect pickerRect = CGRectMake(0.0,
									   screenRect.origin.y + screenRect.size.height - pickerSize.height,
									   pickerSize.width,
									   pickerSize.height);
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];
		
		// we need to perform some post operations after the animation is complete
		[UIView setAnimationDelegate:self];
		
		valueSelect.frame = pickerRect;
		
		// shrink the table vertical size to make room for the date picker
		CGRect newFrame = self.tableView.frame;
		newFrame.size.height -= valueSelect.frame.size.height;
		self.tableView.frame = newFrame;
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
		self.navigationItem.rightBarButtonItem = doneButton;
	}
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
	NSLog(@"indexPath: %@", indexPath);
	editIndexPath = indexPath;
	components = [[pickerOptions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	[valueSelect reloadAllComponents];

	switch (editIndexPath.row) {
		case SEX_ROW:
			[valueSelect selectRow:[[me sex] intValue] inComponent:0 animated:NO];
			break;
		case AGE_ROW:
			[valueSelect selectRow:[[me age] intValue] inComponent:0 animated:NO];
			break;
		case HEIGHT_ROW: // TODO: display metric system unless user local is USA
			if (TRUE) { // detect if we're in USA. how?
				[valueSelect selectRow:[[me height] intValue] inComponent:0 animated:NO]; // feet
				[valueSelect selectRow:[[me height] intValue] inComponent:1 animated:NO]; // inches
			} else {
				[valueSelect selectRow:[[me height] intValue] inComponent:0 animated:NO]; // cm
			}
			break;
		case WEIGHT_ROW: // TODO: display metric system unless user local is USA
			[valueSelect selectRow:[[me weight] intValue] inComponent:0 animated:NO];
			break;
		case ETHNICITY_ROW:
			[valueSelect selectRow:[[me ethnicity] intValue] inComponent:0 animated:NO];
			break;
		default:
			[valueSelect selectRow:0 inComponent:0 animated:NO];
			break;
	}
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//	self.navigationItem.rightBarButtonItem = textDone;
//}
//
//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//	self.navigationItem.rightBarButtonItem = textDone;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSLog(@"Selected Color: %@. Index of selected color: %i", [[components objectAtIndex:component] objectAtIndex:row], row);
	NSLog(@"editIndexPath: %@", editIndexPath);

	NSString *valueText = [[components objectAtIndex:component] objectAtIndex:row];
	switch (editIndexPath.row) {
		case SEX_ROW:
			[me setSex:[NSNumber numberWithInt:row]];
			break;
		case AGE_ROW:
			[me setAge:[NSNumber numberWithInt:row]];
			break;
		case HEIGHT_ROW: // TODO: display metric system unless user local is USA
			// we should create a global mutable array: heightPicked = [int feet, int inches]
			// actually, do we need mutable? can we use nsarray since we are not adding objects?
			// just changing them in place...
			// something like this..
//			NSMutableArray *heightPicked = [[NSMutableArray alloc] initWithObjects:[self feetFromHeight([me height])],
//											[self inchesFromHeight([me height])]];
			
			// calculate total inches and convert to cm and save to height
//			int heightInCm = 67; // calculate...
//			[me setHeight:[NSNumber numberWithInt:heightInCm]];
			[me setHeight:[NSNumber numberWithInt:row]];
			break;
		case WEIGHT_ROW: // TODO: display metric system unless user local is USA
			[me setWeight:[NSNumber numberWithInt:row]];
			if (TRUE) {
				valueText = [NSString stringWithFormat:@"%@ lbs", valueText];
			} else {
				valueText = [NSString stringWithFormat:@"%@ kg", valueText];
			}
			break;
		case ETHNICITY_ROW:
			[me setEthnicity:[NSNumber numberWithInt:row]];
			break;
		default:
			break;
	}

	[self.tableView cellForRowAtIndexPath:editIndexPath].detailTextLabel.text = valueText; // set text for UILabel

//	[[[profileValues objectAtIndex:editIndexPath.section] objectAtIndex:editIndexPath.row] setString:valueText];
//	[[[profileValues objectAtIndex:editIndexPath.section]
//	  objectAtIndex:editIndexPath.row] setText:[components objectAtIndex:row]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [components count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSLog(@"valueSelect rows count: %d", [[components objectAtIndex:component] count]);
	return [[components objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSLog(@"object: %@", [[components objectAtIndex:component] objectAtIndex:row]);
	
	NSString *valueTitle = [[components objectAtIndex:component] objectAtIndex:row];
	switch (editIndexPath.row) {
		case WEIGHT_ROW: // TODO: display metric system unless user local is USA
			if (TRUE) {
				return [NSString stringWithFormat:@"%@ lbs", valueTitle];
			} else {
				return [NSString stringWithFormat:@"%@ kg", valueTitle];
			}
			break;
		default:
			return valueTitle;
			break;
	}
}

//- (void)shrinkTableView {
//	[self slideFrame:YES];
//}
//
//// Shorten height of UITableView when picker/keyboard pops up
//- (void)slideFrame:(BOOL)up {
//	const int movementDistance = 216.0f; // set to keyboard variable	
//	int movement = (up ? -movementDistance : movementDistance);
//	
//	[UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//
//	CGRect viewFrame = self.tableView.frame;
//	viewFrame.size.height += movement;
//	self.tableView.frame = viewFrame;
//
//	CGRect pickerFrame = valueSelect.frame;
//	pickerFrame.size.height -= movement;
//	self.tableView.frame = viewFrame;
//
//	[UIView commitAnimations];
//}

// Add to TableView (I think by subclassing UITableView, i.e.,
// @interface TouchableTableView : UITableView
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = [touches anyObject];
//	
//	// pass touches up to viewController
//	[self.nextResponder touchesBegan:touches withEvent:event];
//}
//
// Then, put this in this file (UIViewController)
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [[event allTouches] anyObject];
//    if ([valueInput isFirstResponder] && [touch view] != valueInput) {
//        [valueInput resignFirstResponder];
//    }
//    [super touchesBegan:touches withEvent:event];
//}

- (void)slideDownDidStop {
	[valueSelect removeFromSuperview];
}

- (void)donePickingValue:(id)sender {
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = valueSelect.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
	valueSelect.frame = endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += valueSelect.frame.size.height;
	self.tableView.frame = newFrame;
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = saveButton;
	
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)doneEditingText:(id)sender {
//  // TODO: use something like this:
//	switch (editIndexPath.row) {
//		case 0:
//			break;
//		default:
//			break;
//	}
	[me setAbout:aboutInput.text];
	[aboutInput resignFirstResponder];

	[me setName:profileName.text];
	[profileName resignFirstResponder];
	
	[me setFbUsername:valueInput.text];
	[valueInput resignFirstResponder];
}

- (void)clearChats:(id)sender {
	NSManagedObjectContext *managedObjectContext = [(LoversAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO];
	
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted", @"Message");
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error: %@", @"Message", error);
    }
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}

- (void)dealloc {
	[me release];
	[profileHeader release];
	[valueSelect release];
	[avatarImg release];
    [super dealloc];
}

@end
