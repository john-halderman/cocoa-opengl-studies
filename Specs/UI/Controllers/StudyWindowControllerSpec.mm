#import "StudyController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(StudyWindowControllerSpec)

describe(@"StudyController", ^{
    __block StudyController *controller;

    beforeEach(^{
		controller = [[StudyController alloc] init];
    });
});

SPEC_END
