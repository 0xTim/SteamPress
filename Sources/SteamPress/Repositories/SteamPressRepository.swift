import Vapor

public protocol BlogTagRepository {
    func getAllTags(on req: Request) -> Future<[BlogTag]>
    func getTagsFor(post: BlogPost, on req: Request) -> Future<[BlogTag]>
}

public protocol BlogPostRepository {
    func getAllPosts(on req: Request) -> Future<[BlogPost]>
    func getAllPostsSortedByPublishDate(on req: Request, includeDrafts: Bool) -> Future<[BlogPost]>
}

public protocol BlogUserRepository {
    func getAllUsers(on req: Request) -> Future<[BlogUser]>
    func getUser(_ id: Int, on req: Request) -> Future<BlogUser?>
}
