import Foundation

// MARK: - Post Model

struct Post: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let authorId: UUID
    var content: String
    var imageURL: String?
    var likesCount: Int
    var commentsCount: Int
    var isLikedByCurrentUser: Bool
    let createdAt: Date
    var updatedAt: Date

    // Populated from join
    var author: User?

    enum CodingKeys: String, CodingKey {
        case id
        case authorId = "author_id"
        case content
        case imageURL = "image_url"
        case likesCount = "likes_count"
        case commentsCount = "comments_count"
        case isLikedByCurrentUser = "is_liked_by_current_user"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case author
    }

    // MARK: - Computed Properties

    var hasImage: Bool {
        imageURL != nil
    }

    var formattedDate: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: createdAt)
        }
    }

    var engagementCount: Int {
        likesCount + commentsCount
    }
}

// MARK: - Comment Model

struct Comment: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let postId: UUID
    let authorId: UUID
    var content: String
    let createdAt: Date

    // Populated from join
    var author: User?

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case authorId = "author_id"
        case content
        case createdAt = "created_at"
        case author
    }

    var formattedDate: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Like Model

struct Like: Codable, Identifiable, Sendable {
    let id: UUID
    let postId: UUID
    let userId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

// MARK: - Mock Data

extension Post {
    static let mock = Post(
        id: UUID(),
        authorId: UUID(),
        content: "Just had the most amazing coffee at this new spot downtown. Anyone else been? The atmosphere is incredible and the baristas really know their stuff.",
        imageURL: nil,
        likesCount: 24,
        commentsCount: 8,
        isLikedByCurrentUser: false,
        createdAt: Date().addingTimeInterval(-3600),
        updatedAt: Date().addingTimeInterval(-3600),
        author: .mock
    )

    static let mockWithImage = Post(
        id: UUID(),
        authorId: UUID(),
        content: "Weekend vibes",
        imageURL: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
        likesCount: 156,
        commentsCount: 32,
        isLikedByCurrentUser: true,
        createdAt: Date().addingTimeInterval(-7200),
        updatedAt: Date().addingTimeInterval(-7200),
        author: .mock
    )

    static let mockPosts: [Post] = [
        mock,
        mockWithImage,
        Post(
            id: UUID(),
            authorId: UUID(),
            content: "Looking for hiking buddies this weekend! Planning to hit the trails early Saturday morning. Who's in?",
            imageURL: nil,
            likesCount: 45,
            commentsCount: 12,
            isLikedByCurrentUser: false,
            createdAt: Date().addingTimeInterval(-14400),
            updatedAt: Date().addingTimeInterval(-14400),
            author: .mock
        )
    ]
}

extension Comment {
    static let mock = Comment(
        id: UUID(),
        postId: UUID(),
        authorId: UUID(),
        content: "This is amazing! Where is this place?",
        createdAt: Date().addingTimeInterval(-1800),
        author: .mock
    )
}
