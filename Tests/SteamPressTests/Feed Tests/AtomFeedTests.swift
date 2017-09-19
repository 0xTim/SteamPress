@testable import SteamPress
import XCTest
import Vapor
import FluentProvider

class AtomFeedTests: XCTestCase {
    
    // MARK: - allTests
    
    static var allTests = [
        ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
        ("testNoPostsReturnsCorrectAtomFeed", testNoPostsReturnsCorrectAtomFeed),
        ("testThatFeedTitleCanBeConfigured", testThatFeedTitleCanBeConfigured),
        ("testThatFeedSubtitleCanBeConfigured", testThatFeedSubtitleCanBeConfigured),
        ("testThatRightsCanBeConifgured", testThatRightsCanBeConifgured),
        ("testThatLinksAreCorrectForFullURI", testThatLinksAreCorrectForFullURI),
        ("testThatHTTPSLinksWorkWhenBehindReverseProxy", testThatHTTPSLinksWorkWhenBehindReverseProxy),
        ("testThatLogoCanBeConfigured", testThatLogoCanBeConfigured),
        ("testThatFeedIsCorrectForOnePost", testThatFeedIsCorrectForOnePost),
        ("testThatFeedCorrectForTwoPosts", testThatFeedCorrectForTwoPosts),
        ("testThatDraftsDontAppearInFeed", testThatDraftsDontAppearInFeed),
        ("testThatEditedPostsHaveUpdatedTimes", testThatEditedPostsHaveUpdatedTimes),
        ("testThatTagsAppearWhenPostHasThem", testThatTagsAppearWhenPostHasThem),
        ("testThatFullLinksWorksForPosts", testThatFullLinksWorksForPosts),
        ("testThatHTTPSLinksWorkForPostsBehindReverseProxy", testThatHTTPSLinksWorkForPostsBehindReverseProxy),
        ]
    
    // MARK: - Properties
    private var database: Database!
    private var drop: Droplet!
    private let atomRequest = Request(method: .get, uri: "/atom.xml")
    private let dateFormatter = DateFormatter()
    
    // MARK: - Overrides
    
    override func setUp() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
    
    // MARK: - Tests
    
    func testLinuxTestSuiteIncludesAllTests() {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let thisClass = type(of: self)
            let linuxCount = thisClass.allTests.count
            let darwinCount = Int(thisClass
                .defaultTestSuite().testCaseCount)
            XCTAssertEqual(linuxCount, darwinCount,
                           "\(darwinCount - linuxCount) tests are missing from allTests")
        #endif
    }
    
    func testNoPostsReturnsCorrectAtomFeed() throws {
        drop = try TestDataBuilder.setupSteamPressDrop()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedTitleCanBeConfigured() throws {
        let title = "My Awesome Blog"
        drop = try TestDataBuilder.setupSteamPressDrop(title: title)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>\(title)</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedSubtitleCanBeConfigured() throws {
        let description = "This is a test for my blog"
        drop = try TestDataBuilder.setupSteamPressDrop(description: description)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>\(description)</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatRightsCanBeConifgured() throws {
        let copyright = "Copyright ©️ 2017 SteamPress"
        drop = try TestDataBuilder.setupSteamPressDrop(copyright: copyright)
        
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<rights>\(copyright)</rights>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatLinksAreCorrectForFullURI() throws {
        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let request = Request(method: .get, uri: "https://geeks.brokenhands.io/blog/atom.xml")
        let actualXmlResponse = try drop.respond(to: request)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatHTTPSLinksWorkWhenBehindReverseProxy() throws {
        drop = try TestDataBuilder.setupSteamPressDrop(path: "blog")
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>https://geeks.brokenhands.io/blog/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"https://geeks.brokenhands.io/blog/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"https://geeks.brokenhands.io/blog/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n</feed>"
        
        let request = Request(method: .get, uri: "http://geeks.brokenhands.io/blog/atom.xml")
        request.headers["X-Forwarded-Proto"] = "https"
        let actualXmlResponse = try drop.respond(to: request)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatLogoCanBeConfigured() throws {
        let imageURL = "https://static.brokenhands.io/images/feeds/atom.png"
        drop = try TestDataBuilder.setupSteamPressDrop(imageURL: imageURL)
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<logo>\(imageURL)</logo>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedIsCorrectForOnePost() throws {
        drop = try TestDataBuilder.setupSteamPressDrop()
        let (post, author) = try createPost()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try drop.respond(to: atomRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatFeedCorrectForTwoPosts() throws {
        drop = try TestDataBuilder.setupSteamPressDrop()
        let (post, author) = try createPost()
        let secondTitle = "Another Post"
        let secondPostDate = Date()
        let post2 = BlogPost(title: secondTitle, contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: secondPostDate, slugUrl: "another-post", published: true)
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: secondPostDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatDraftsDontAppearInFeed() throws {
        drop = try TestDataBuilder.setupSteamPressDrop()
        let (post, author) = try createPost()
        let post2 = BlogPost(title: "Another Post", contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: Date(), slugUrl: "another-post", published: false)
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: Date()))</updated>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: post.created))</updated>\n<published>\(dateFormatter.string(from: post.created))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"
        
        let actualXmlResponse = try drop.respond(to: atomRequest)
        
        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatEditedPostsHaveUpdatedTimes() throws {
        drop = try TestDataBuilder.setupSteamPressDrop()
        let firstPostDate = Date().addingTimeInterval(-3600)
        let (post, author) = try createPost(createDate: firstPostDate)
        let secondTitle = "Another Post"
        let secondPostDate = Date().addingTimeInterval(-60)
        let newEditDate = Date()
        let post2 = BlogPost(title: secondTitle, contents: "#Some Interesting Post\nThis contains a load of contents...", author: author, creationDate: secondPostDate, slugUrl: "another-post", published: true)
        post2.lastEdited = newEditDate
        try post2.save()
        let expectedXML = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<feed xmlns=\"http://www.w3.org/2005/Atom\">\n\n<title>SteamPress Blog</title>\n<subtitle>SteamPress is an open-source blogging engine written for Vapor in Swift</subtitle>\n<id>/</id>\n<link rel=\"alternate\" type=\"text/html\" href=\"/\"/>\n<link rel=\"self\" type=\"application/atom+xml\" href=\"/atom.xml\"/>\n<generator uri=\"https://www.steampress.io/\">SteamPress</generator>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<entry>\n<id>/posts-id/2/</id>\n<title>\(secondTitle)</title>\n<updated>\(dateFormatter.string(from: newEditDate))</updated>\n<published>\(dateFormatter.string(from: secondPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post2.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post2.slugUrl)/\" />\n</entry>\n<entry>\n<id>/posts-id/1/</id>\n<title>\(post.title)</title>\n<updated>\(dateFormatter.string(from: firstPostDate))</updated>\n<published>\(dateFormatter.string(from: firstPostDate))</published>\n<author>\n<name>\(author.name)</name>\n<uri>/authors/\(author.username)/</uri>\n</author>\n<summary>\(try post.description())</summary>\n<link rel=\"alternate\" href=\"/posts/\(post.slugUrl)/\" />\n</entry>\n</feed>"

        let actualXmlResponse = try drop.respond(to: atomRequest)

        XCTAssertEqual(actualXmlResponse.body.bytes?.makeString(), expectedXML)
    }
    
    func testThatTagsAppearWhenPostHasThem() throws {
        
    }
    
    func testThatFullLinksWorksForPosts() throws {
        
    }
    
    func testThatHTTPSLinksWorkForPostsBehindReverseProxy() throws {
        
    }
    
    // MARK: - Private functions
    
    private func createPost(tags: [String]? = nil, createDate: Date? = nil) throws -> (BlogPost, BlogUser) {
        let author = TestDataBuilder.anyUser()
        try author.save()
        let post = TestDataBuilder.anyPost(author: author, creationDate: createDate ?? Date())
        try post.save()
        
        if let tags = tags {
            for tag in tags {
                try BlogTag.addTag(tag, to: post)
            }
        }
        
        return (post, author)
    }
}
