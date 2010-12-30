//static NSString *kHost @"acani.heroku.com"
static NSString *kHost = @"localhost:4567";

#define BAR_BUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define BAR_BUTTON_TARGET(TITLE, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:TARGET action:SELECTOR]

#define ACANI_RED [UIColor colorWithRed:230.0/255 green:30.0/255 blue:43.0/255 alpha:1]
#define CHAT_BACKGROUND_COLOR [UIColor colorWithRed:0.859 green:0.886 blue:0.929 alpha:1.0] // => [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];

#define DATA_FROM_STRING(STRING) [STRING dataUsingEncoding:NSUTF8StringEncoding]

// Posting constants
static NSString *kUserAgent = @"acani";
static NSString *kMultipart = @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x";
static NSString *kStringBoundary = @"------------0x0x0x0x0x0x0x0x";
static NSString *kImageContent = @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n";
static NSString *kStringContent = @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n";

//#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)
//void myShowAlert(int line, char *functname, id formatstring,...);

//void displayRefreshButton(UIViewController controller, NSString buttonTitle, SEL buttonSelector);
