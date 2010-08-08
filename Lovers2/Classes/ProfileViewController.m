#import "LoversAppDelegate.h"
#import "ProfileViewController.h"

#define MAINLABEL	((UILabel *)self.navigationItem.titleView)

@implementation ProfileViewController

- (ProfileViewController *) init {
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
	self.view.backgroundColor = [UIColor whiteColor];

	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
								   initWithTitle:@"Lovers"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(back:)];
	self.navigationItem.leftBarButtonItem = backButton;
	[backButton release];

	profileContent = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 244.0f) style:UITableViewStyleGrouped];
	profileContent.clearsContextBeforeDrawing = NO;
	profileContent.delegate = self;
	profileContent.dataSource = self;
	profileContent.autoresizingMask = UIViewAutoresizingFlexibleHeight;	

	// set up the table's header view based on our UIView 'myHeaderView' outlet
	profileHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, 86.0f)];
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
	[profileHeader addSubview:profileName];
	[profileName release];

	profileContent.tableHeaderView = profileHeader;	// note this overrides UITableView's 'sectionHeaderHeight' property

	[self.view addSubview:profileContent];
	[profileContent release];

	valueSelect = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200.0f, 320.0f, 220.0f)];
//	valueSelect.clearsContextBeforeDrawing = NO;
	valueSelect.showsSelectionIndicator = YES;
	valueSelect.delegate = self;
	[self.view addSubview:valueSelect];

//	int height = 22.0f;
	profileFields = [[NSArray alloc] initWithObjects:
					 [[NSArray alloc] initWithObjects:@"About",@"Age",@"Height",@"Weight",@"Ethnicity",@"Facebook",nil],
					 [[NSArray alloc] initWithObjects:@"Distance",@"Age Filter",nil], nil];
	
//	profileValues =	[[NSArray alloc] initWithObjects:
//					 [[NSArray alloc] initWithObjects:
//					  aboutInput,
//					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
//					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
//					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
//					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
//					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],nil],
//					 [[NSArray alloc] initWithObjects:
//					  [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)],
//				      [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)], nil], nil];

	valueSelects = [[NSArray alloc] initWithObjects:
					[[NSArray alloc] initWithObjects:
					 [[NSArray alloc] initWithObjects:@"", nil],
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"Do Not Show", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39", @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49", @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59", @"60", @"61", @"62", @"63", @"64", @"65", @"66", @"67", @"68", @"69", @"70", @"71", @"72", @"73", @"74", @"75", @"76", @"77", @"78", @"79", @"80", @"81", @"82", @"83", @"84", @"85", @"86", @"87", @"88", @"89", @"91", @"92", @"93", @"94", @"95", @"96", @"97", @"98", @"99", @"100", nil], nil],
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"Do Not Show", @"5 feet", @"6 feet", @"7 feet", nil],
					  [[NSArray alloc] initWithObjects:@"0 inches", @"1 inches", @"2 inches", @"3 inches", @"4 inches", @"5 inches", @"6 inches", @"7 inches", @"8 inches", @"9 inches", @"10 inches", @"11 inches", nil], nil],
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"Do Not Show", @"100 lbs", @"101 lbs", @"102 lbs", @"103 lbs", @"104 lbs", @"105 lbs", @"106 lbs", @"107 lbs", @"108 lbs", @"109 lbs", @"110 lbs", @"111 lbs", @"112 lbs", @"113 lbs", @"114 lbs", @"115 lbs", @"116 lbs", @"117 lbs", @"118 lbs", @"119 lbs", @"120 lbs", @"121 lbs", @"122 lbs", @"123 lbs", @"124 lbs", @"125 lbs", @"126 lbs", @"127 lbs", @"128 lbs", @"129 lbs", @"130 lbs", @"131 lbs", @"132 lbs", @"133 lbs", @"134 lbs", @"135 lbs", @"136 lbs", @"137 lbs", @"138 lbs", @"139 lbs", @"140 lbs", @"141 lbs", @"142 lbs", @"143 lbs", @"144 lbs", @"145 lbs", @"146 lbs", @"147 lbs", @"148 lbs", @"149 lbs", @"150 lbs", @"151 lbs", @"152 lbs", @"153 lbs", @"154 lbs", @"155 lbs", @"156 lbs", @"157 lbs", @"158 lbs", @"159 lbs", @"160 lbs", @"161 lbs", @"162 lbs", @"163 lbs", @"164 lbs", @"165 lbs", @"166 lbs", @"167 lbs", @"168 lbs", @"169 lbs", @"170 lbs", @"171 lbs", @"172 lbs", @"173 lbs", @"174 lbs", @"175 lbs", @"176 lbs", @"177 lbs", @"178 lbs", @"179 lbs", @"180 lbs", @"181 lbs", @"182 lbs", @"183 lbs", @"184 lbs", @"185 lbs", @"186 lbs", @"187 lbs", @"188 lbs", @"189 lbs", @"190 lbs", @"191 lbs", @"192 lbs", @"193 lbs", @"194 lbs", @"195 lbs", @"196 lbs", @"197 lbs", @"198 lbs", @"199 lbs", @"200 lbs", @"201 lbs", @"202 lbs", @"203 lbs", @"204 lbs", @"205 lbs", @"206 lbs", @"207 lbs", @"208 lbs", @"209 lbs", @"210 lbs", @"211 lbs", @"212 lbs", @"213 lbs", @"214 lbs", @"215 lbs", @"216 lbs", @"217 lbs", @"218 lbs", @"219 lbs", @"220 lbs", @"221 lbs", @"222 lbs", @"223 lbs", @"224 lbs", @"225 lbs", @"226 lbs", @"227 lbs", @"228 lbs", @"229 lbs", @"230 lbs", @"231 lbs", @"232 lbs", @"233 lbs", @"234 lbs", @"235 lbs", @"236 lbs", @"237 lbs", @"238 lbs", @"239 lbs", @"240 lbs", @"241 lbs", @"242 lbs", @"243 lbs", @"244 lbs", @"245 lbs", @"246 lbs", @"247 lbs", @"248 lbs", @"249 lbs", @"250 lbs", @"251 lbs", @"252 lbs", @"253 lbs", @"254 lbs", @"255 lbs", @"256 lbs", @"257 lbs", @"258 lbs", @"259 lbs", @"260 lbs", @"261 lbs", @"262 lbs", @"263 lbs", @"264 lbs", @"265 lbs", @"266 lbs", @"267 lbs", @"268 lbs", @"269 lbs", @"270 lbs", @"271 lbs", @"272 lbs", @"273 lbs", @"274 lbs", @"275 lbs", @"276 lbs", @"277 lbs", @"278 lbs", @"279 lbs", @"280 lbs", @"281 lbs", @"282 lbs", @"283 lbs", @"284 lbs", @"285 lbs", @"286 lbs", @"287 lbs", @"288 lbs", @"289 lbs", @"290 lbs", @"291 lbs", @"292 lbs", @"293 lbs", @"294 lbs", @"295 lbs", @"296 lbs", @"297 lbs", @"298 lbs", @"299 lbs", @"300 lbs", @"301 lbs", @"302 lbs", @"303 lbs", @"304 lbs", @"305 lbs", @"306 lbs", @"307 lbs", @"308 lbs", @"309 lbs", @"310 lbs", @"311 lbs", @"312 lbs", @"313 lbs", @"314 lbs", @"315 lbs", @"316 lbs", @"317 lbs", @"318 lbs", @"319 lbs", @"320 lbs", @"321 lbs", @"322 lbs", @"323 lbs", @"324 lbs", @"325 lbs", @"326 lbs", @"327 lbs", @"328 lbs", @"329 lbs", @"330 lbs", @"331 lbs", @"332 lbs", @"333 lbs", @"334 lbs", @"335 lbs", @"336 lbs", @"337 lbs", @"338 lbs", @"339 lbs", @"340 lbs", @"341 lbs", @"342 lbs", @"343 lbs", @"344 lbs", @"345 lbs", @"346 lbs", @"347 lbs", @"348 lbs", @"349 lbs", @"350 lbs", @"351 lbs", @"352 lbs", @"353 lbs", @"354 lbs", @"355 lbs", @"356 lbs", @"357 lbs", @"358 lbs", @"359 lbs", @"360 lbs", @"361 lbs", @"362 lbs", @"363 lbs", @"364 lbs", @"365 lbs", @"366 lbs", @"367 lbs", @"368 lbs", @"369 lbs", @"370 lbs", @"371 lbs", @"372 lbs", @"373 lbs", @"374 lbs", @"375 lbs", @"376 lbs", @"377 lbs", @"378 lbs", @"379 lbs", @"380 lbs", @"381 lbs", @"382 lbs", @"383 lbs", @"384 lbs", @"385 lbs", @"386 lbs", @"387 lbs", @"388 lbs", @"389 lbs", @"390 lbs", @"391 lbs", @"392 lbs", @"393 lbs", @"394 lbs", @"395 lbs", @"396 lbs", @"397 lbs", @"398 lbs", @"399 lbs", @"400 lbs", nil], nil],
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"Do Not Show", @"Asian", @"Black", @"Latino", @"Middle Eastern", @"Mixed", @"Native American", @"White", @"Other", nil], nil],
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"Distance", @"Age Filter", @"w", nil], nil], nil],
					[[NSArray alloc] initWithObjects:
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"15",@"16", @"1", nil], nil],
					 [[NSArray alloc] initWithObjects:
					  [[NSArray	alloc] initWithObjects:@"1", @"2", @"3", nil], nil], nil], nil];
	
	valueSelectArray = [[valueSelects objectAtIndex:0] objectAtIndex:0];

	NSLog(@"valueSelects: %@", valueSelects);
	NSLog(@"valueSelects obj: %@", [[[valueSelects objectAtIndex:0] objectAtIndex:1] objectAtIndex:1]);
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
    return [profileFields count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[profileFields objectAtIndex:section] count];
}

#define VALUE_TAG 121
#define ABOUT_TAG 122

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";

	UILabel *value;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//		cell.selectionStyle = UITableViewCellSelectionStyleNone;

		cell.textLabel.text = [[profileFields objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

		if (indexPath.section == 0 && indexPath.row == 0) {
			aboutInput = [[UITextView alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, 50.0f)];
			//	aboutInput.scrollEnabled = NO;
			aboutInput.clearsContextBeforeDrawing = NO;
			aboutInput.font = [UIFont systemFontOfSize:14.0];
			//	aboutInput.dataDetectorTypes = UIDataDetectorTypeAll;
			aboutInput.backgroundColor = [UIColor grayColor];
			aboutInput.contentOffset = CGPointMake(0.0f, 6.0f); // fix quirk
			aboutInput.delegate = self;			
			aboutInput.tag = ABOUT_TAG;
			[cell.contentView addSubview:aboutInput];
			[aboutInput release];
		} else {
			int height = 22.0f;
			value = [[UILabel alloc] initWithFrame:CGRectMake(94.0f, 4.0f, 180.0f, height)];
//			value = [[profileValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
			value.tag = VALUE_TAG;
			[cell.contentView addSubview:value];
			[value release];
//			[cell.contentView addSubview:[[profileValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
		}
	}
//	else {
//		value = (UILabel *)[cell.contentView viewWithTag:VALUE_TAG];
//		aboutInput = (UITextView *)[cell.contentView viewWithTag:ABOUT_TAG];		
//	}

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
	
	NSLog(@"1: %d, %d", indexPath.section, indexPath.row);
	editIndexPath = indexPath;
	valueSelectArray = [[valueSelects objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

	[valueSelect reloadAllComponents];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSLog(@"Selected Color: %@. Index of selected color: %i", [valueSelectArray objectAtIndex:row], row);
	NSLog(@"editIndexPath: %@", editIndexPath);
	
	// Set text for UILabel
	[(UILabel *)[[profileContent cellForRowAtIndexPath:editIndexPath].contentView viewWithTag:VALUE_TAG] setText:[valueSelectArray objectAtIndex:row]];

//	[[[profileValues objectAtIndex:editIndexPath.section]
//	  objectAtIndex:editIndexPath.row] setText:[valueSelectArray objectAtIndex:row]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [valueSelectArray count];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSLog(@"valueSelect rows count: %d", [[valueSelectArray objectAtIndex:component] count]);
	return [[valueSelectArray objectAtIndex:component] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSLog(@"object: %@", [[valueSelectArray objectAtIndex:component] objectAtIndex:row]);
	return [[valueSelectArray objectAtIndex:component] objectAtIndex:row];
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
	[valueSelect release];
    [super dealloc];
}

@end
