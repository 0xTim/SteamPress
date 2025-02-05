import Vapor
import SteamPress

class InMemoryRepository: BlogTagRepository, BlogPostRepository, BlogUserRepository, Service {
    
    private(set) var tags: [BlogTag]
    private(set) var posts: [BlogPost]
    private(set) var users: [BlogUser]
    private var postTagLinks: [BlogPostTagLink]
    
    init() {
        tags = []
        posts = []
        users = []
        postTagLinks = []
    }
    
    // MARK: - BlogTagRepository
    
    func getAllTags(on container: Container) -> Future<[BlogTag]> {
        return container.future(tags)
    }
    
    func getTags(for post: BlogPost, on container: Container) -> EventLoopFuture<[BlogTag]> {
        var results = [BlogTag]()
        guard let postID = post.blogID else {
            fatalError("Post doesn't exist when it should")
        }
        for link in postTagLinks where link.postID == postID {
            let foundTag = tags.first { $0.tagID == link.tagID }
            guard let tag =  foundTag else {
                fatalError("Tag doesn't exist when it should")
            }
            results.append(tag)
        }
        return container.future(results)
    }
    
    func addTag(name: String) throws -> BlogTag {
        let newTag = try BlogTag(id: tags.count + 1, name: name)
        tags.append(newTag)
        return newTag
    }
    
    func addTag(name: String, for post: BlogPost) throws -> BlogTag{
        let newTag = try addTag(name: name)
        guard let postID = post.blogID else {
            fatalError("Blog doesn't exist when it should")
        }
        guard let tagID = newTag.tagID else {
            fatalError("Tag ID hasn't been set")
        }
        let newLink = BlogPostTagLink(postID: postID, tagID: tagID)
        postTagLinks.append(newLink)
        return newTag
    }
    
    func getTag(_ name: String, on container: Container) -> EventLoopFuture<BlogTag?> {
        return container.future(tags.first { $0.name == name })
    }
    
    func addTag(_ tag: BlogTag, to post: BlogPost) {
        guard let postID = post.blogID else {
            fatalError("Blog doesn't exist when it should")
        }
        guard let tagID = tag.tagID else {
            fatalError("Tag ID hasn't been set")
        }
        let newLink = BlogPostTagLink(postID: postID, tagID: tagID)
        postTagLinks.append(newLink)
    }
    
    // MARK: - BlogPostRepository
    
    func getAllPosts(on container: Container) -> EventLoopFuture<[BlogPost]> {
        return container.future(posts)
    }
    
    func getAllPostsSortedByPublishDate(includeDrafts: Bool, on container: Container) -> EventLoopFuture<[BlogPost]> {
        var sortedPosts = posts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        return container.future(sortedPosts)
    }
    
    func getAllPostsSortedByPublishDate(for user: BlogUser, includeDrafts: Bool, on container: Container) -> EventLoopFuture<[BlogPost]> {
        let authorsPosts = posts.filter { $0.author == user.userID }
        var sortedPosts = authorsPosts.sorted { $0.created > $1.created }
        if !includeDrafts {
            sortedPosts = sortedPosts.filter { $0.published }
        }
        return container.future(sortedPosts)
    }
    
    func getPost(slug: String, on container: Container) -> EventLoopFuture<BlogPost?> {
        return container.future(posts.first { $0.slugUrl == slug })
    }
    
    func getPost(id: Int, on container: Container) -> EventLoopFuture<BlogPost?> {
        return container.future(posts.first { $0.blogID == id })
    }
    
    func getSortedPublishedPosts(for tag: BlogTag, on container: Container) -> EventLoopFuture<[BlogPost]> {
        var results = [BlogPost]()
        guard let tagID = tag.tagID else {
            fatalError("Tag doesn't exist when it should")
        }
        for link in postTagLinks where link.tagID == tagID {
            let foundPost = posts.first { $0.blogID == link.postID }
            guard let post =  foundPost else {
                fatalError("Post doesn't exist when it should")
            }
            results.append(post)
        }
        let sortedPosts = results.sorted { $0.created > $1.created }.filter { $0.published }
        return container.future(sortedPosts)
    }
    
    func findPublishedPostsOrdered(for searchTerm: String, on container: Container) -> EventLoopFuture<[BlogPost]> {
        let titleResults = posts.filter { $0.title.contains(searchTerm) }
        let results = titleResults.sorted { $0.created > $1.created }.filter { $0.published }
        return container.future(results)
    }
    
    func save(_ post: BlogPost, on container: Container) -> EventLoopFuture<BlogPost> {
        self.add(post)
        return container.future(post)
    }
    
    func add(_ post: BlogPost) {
        if (posts.first { $0.blogID == post.blogID } == nil) {
            post.blogID = posts.count + 1
            posts.append(post)
        }
    }
    
    func delete(_ post: BlogPost, on container: Container) -> EventLoopFuture<Void> {
        posts.removeAll { $0.blogID == post.blogID }
        return container.future()
    }
    
    // MARK: - BlogUserRepository
    
    func add(_ user: BlogUser) {
        if (users.first { $0.userID == user.userID } == nil) {
            if (users.first { $0.username == user.username} != nil) {
                fatalError("Duplicate users added with username \(user.username)")
            }
            user.userID = users.count + 1
            users.append(user)
        }
    }
    
    func getUser(id: Int, on container: Container) -> EventLoopFuture<BlogUser?> {
        return container.future(users.first { $0.userID == id })
    }
    
    func getUser(name: String, on container: Container) -> EventLoopFuture<BlogUser?> {
        return container.future(users.first { $0.name == name })
    }
    
    func getAllUsers(on container: Container) -> EventLoopFuture<[BlogUser]> {
        return container.future(users)
    }
    
    func getUser(username: String, on container: Container) -> EventLoopFuture<BlogUser?> {
        return container.future(users.first { $0.username == username })
    }
    
    private(set) var userUpdated = false
    func save(_ user: BlogUser, on container: Container) -> EventLoopFuture<BlogUser> {
        self.add(user)
        userUpdated = true
        return container.future(user)
    }
    
    func delete(_ user: BlogUser, on container: Container) -> EventLoopFuture<Void> {
        users.removeAll { $0.userID == user.userID }
        return container.future()
    }
    
    func getUsersCount(on container: Container) -> EventLoopFuture<Int> {
        return container.future(users.count)
    }
    
}

private struct BlogPostTagLink: Codable {
    let postID: Int
    let tagID: Int
}
