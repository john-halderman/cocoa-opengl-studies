#import "StudyWindowController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(StudyWindowControllerSpec)

describe(@"StudyWindowController", ^{
    __block StudyWindowController *controller;

    beforeEach(^{
		controller = [[StudyWindowController alloc] init];
    });
});

SPEC_END
