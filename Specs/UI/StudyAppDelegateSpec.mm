#import "StudyAppDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(StudyAppDelegateSpec)

describe(@"StudyAppDelegate", ^{
    __block StudyAppDelegate *appDelegate;

    beforeEach(^{
		appDelegate = [[StudyAppDelegate alloc] init];
    });
});

SPEC_END
