#import "Figure.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FigureSpec)

describe(@"Figure", ^{
    __block Figure *figure;

    beforeEach(^{
		figure = [[Figure alloc] init];
    });

	it(@"should not be nil", ^{
		figure should_not be_nil;
	});
});

SPEC_END
