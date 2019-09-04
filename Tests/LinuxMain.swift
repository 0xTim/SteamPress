import XCTest

@testable import SteamPressTests

XCTMain([
//    testCase(BlogPostTests.allTests),
//    testCase(BlogControllerTests.allTests),
//    testCase(BlogAdminControllerTests.allTests),
//    testCase(BlogTagTests.allTests),
//    testCase(LeafViewFactoryTests.allTests),
    testCase(RSSFeedTests.allTests),
    testCase(AtomFeedTests.allTests),
    testCase(APITagControllerTests.allTests),
    testCase(AuthorTests.allTests),
    testCase(AccessControlTests.allTests),
    testCase(AdminPostTests.allTests),
    testCase(IndexTests.allTests),
    testCase(LoginTests.allTests),
    testCase(PostTests.allTests),
    testCase(SearchTests.allTests),
    testCase(TagTests.allTests)
])
