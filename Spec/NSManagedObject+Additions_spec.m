//#define HC_SHORTHAND
//#import <OCHamcrestIOS/OCHamcrestIOS.h>
//
////#import "NSManagedObject+Additions.h"
//
////#import "Constants.h"
//
//SPEC_BEGIN(Constants)
//
//describe(@"Something cool", ^{
//	it(@"should do something eventually", PENDING);
////	it(@"fails for fun", ^{
//////		assertThatBool([example hasChildren], equalToBool(NO));
////		fail(@"This is a fun failure.");
////	});
//});
//	
//
//SPEC_END

//#import "SpecHelper.h"
#import "unistd.h"

SPEC_BEGIN(SlowSpec)

describe(@"Really slow specs", ^{
    it(@"should take a long time", ^{
        sleep(2);
    });
});

SPEC_END
