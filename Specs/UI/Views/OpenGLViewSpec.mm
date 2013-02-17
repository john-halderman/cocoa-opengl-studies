#import "OpenGLView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OpenGLViewSpec)

describe(@"OpenGLView", ^{
    __block OpenGLView *view;

    beforeEach(^{
		view = [[OpenGLView alloc] init];
    });
});

SPEC_END
