#import "Study.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(StudySpec)

describe(@"Study", ^{
    __block Study *study;

    beforeEach(^{
		study = [[Study alloc] init];
    });

	it(@"should not be nil", ^{
		study should_not be_nil;
	});
});

SPEC_END
