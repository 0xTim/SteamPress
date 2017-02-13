import Turnstile
import HTTP
import Cookies
import Foundation
import Cache
import Auth

private let defaultCookieName = "steampress-auth"
private let oneMonthTime: TimeInterval = 30 * 24 * 60 * 60

public class BlogAuthMiddleware: Middleware {
    private let turnstile: Turnstile
    private let cookieName: String
    private let cookieFactory: CookieFactory
    
    public typealias CookieFactory = (String) -> Cookie
    
    public init(
        turnstile: Turnstile,
        cookieName: String = defaultCookieName,
        makeCookie cookieFactory: CookieFactory?
        ) {
        self.turnstile = turnstile
        
        self.cookieName = cookieName
        self.cookieFactory = cookieFactory ?? { value in
            return Cookie(
                name: cookieName,
                value: value,
                expires: nil,
                secure: false,
                httpOnly: true
            )
        }
    }
    
    public convenience init(
        realm: Realm = AuthenticatorRealm(BlogUser.self),
        cache: CacheProtocol = MemoryCache(),
        cookieName: String = defaultCookieName,
        makeCookie cookieFactory: CookieFactory? = nil
        ) {
        let session = CacheSessionManager(cache: cache, realm: realm)
        let turnstile = Turnstile(sessionManager: session, realm: realm)
        self.init(turnstile: turnstile, cookieName: cookieName, makeCookie: cookieFactory)
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        request.storage["subject"] = Subject(
            turnstile: turnstile,
            sessionID: request.cookies[cookieName]
        )
        
        let response = try next.respond(to: request)
        let subject = request.storage["subject"] as? Subject
        
        // If we have a new session, set a new cookie
        if let sid = subject?.authDetails?.sessionID, request.cookies[cookieName] != sid
        {
            var cookie = cookieFactory(sid)
            cookie.name = cookieName
            if request.storage["remember_me"] != nil {
                cookie.expires = Date().addingTimeInterval(oneMonthTime)
            }
            else {
                cookie.expires = nil
            }
            request.storage.removeValue(forKey: "remember_me")
            response.cookies.insert(cookie)
        } else if
            subject?.authDetails?.sessionID == nil,
            request.cookies[cookieName] != nil
        {
            // If we have a cookie but no session, delete it.
            response.cookies[cookieName] = nil
        }
        
        return response
    }
}
