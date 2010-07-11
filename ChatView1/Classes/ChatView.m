#import "ChatView.h"
#import "ChatAppDelegate.h"

static UIImage* sGreenBubble = nil;
static UIImage* sGrayBubble = nil;

@interface ChatView(Private)
+ (UIImage*)greenBubble;
+ (UIImage*)grayBubble;
@end

@implementation ChatView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.859 green:0.886 blue:0.929 alpha:1.0];
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
//    CGContextRef c = UIGraphicsGetCurrentContext();
    
    //
    // Draw timestamp
    //
	// TODO:
	// * decide which messages have timestamps
	[[UIColor darkGrayColor] set];
	
	[@"Jul 10, 2010 11:55 AM" drawInRect:CGRectMake(0, 4, 320, 16) withFont:[UIFont boldSystemFontOfSize:12]
					  lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];        

    //
    // Draw chat bubble
    //
	CGRect bubbleRect = CGRectMake(0, 40, 200, 60);

    [[ChatView grayBubble] drawInRect:bubbleRect];
    [[ChatView greenBubble] drawInRect:CGRectMake(320-160, 120, 160, 30)];

	//
    // Draw message text
    //
    [[UIColor blackColor] set];
	bubbleRect.origin.x += 20;
    bubbleRect.origin.y += 6;
    [@"Hi, Matt! What's up?" drawInRect:bubbleRect withFont:[UIFont systemFontOfSize:14]];


	//
    // Draw message compose field
    //
	// Text field tutorial
    //	http://icodeblog.com/2010/01/04/uitextfield-a-complete-api-overview/
	 
	UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 400, 300, 30)];
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.textColor = [UIColor blackColor]; //text color
	textField.font = [UIFont systemFontOfSize:17.0];  //font size
	textField.placeholder = @"<enter text>";  //place holder
	textField.backgroundColor = [UIColor whiteColor]; //background color
	textField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support

	textField.keyboardType = UIKeyboardTypeDefault;  // type of the keyboard
	textField.returnKeyType = UIReturnKeyDone;  // type of the return key

	textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right

//	[textField resignFirstResponder];
//	[textField becomeFirstResponder];
	
	[self addSubview:textField];

//	textField.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
}


+ (UIImage*)greenBubble
{
    if (sGreenBubble == nil) {
        UIImage *i = [UIImage imageNamed:@"Balloon_Green.png"];
        sGreenBubble = [[i stretchableImageWithLeftCapWidth:15 topCapHeight:13] retain];
    }
    return sGreenBubble;
}

+ (UIImage*)grayBubble
{
    if (sGrayBubble == nil) {
        UIImage *i = [UIImage imageNamed:@"Balloon_Gray.png"];
        sGrayBubble = [[i stretchableImageWithLeftCapWidth:21 topCapHeight:13] retain];
    }
    return sGrayBubble;
}
@end
