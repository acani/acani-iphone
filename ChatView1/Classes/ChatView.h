#import <UIKit/UIKit.h>
//#import "Message.h"

#define CHAT_BUBBLE_WIDTH           (320 - 32 - 8 - 20 - 20)
#define CHAT_BUBBLE_TEXT_WIDTH      (CHAT_BUBBLE_WIDTH - 30)
#define CHAT_BUBBLE_TIMESTAMP_DIFF  (60 * 30)

typedef enum {
    BUBBLE_TYPE_GRAY,
    BUBBLE_TYPE_GREEN,
} BubbleType;

@interface ChatView : UIView
{
    BubbleType      type;
//    Message*          message;
}

//- (void)setMessage:(Tweet*)message type:(BubbleType)type;

@end
