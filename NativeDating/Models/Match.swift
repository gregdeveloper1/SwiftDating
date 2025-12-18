import Foundation

// MARK: - Match Model

struct Match: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let user1Id: UUID
    let user2Id: UUID
    var lastMessageAt: Date?
    var lastMessage: String?
    let createdAt: Date

    // Populated from join
    var otherUser: User?

    enum CodingKeys: String, CodingKey {
        case id
        case user1Id = "user1_id"
        case user2Id = "user2_id"
        case lastMessageAt = "last_message_at"
        case lastMessage = "last_message"
        case createdAt = "created_at"
        case otherUser = "other_user"
    }

    // MARK: - Computed Properties

    var hasMessages: Bool {
        lastMessageAt != nil
    }

    var isNew: Bool {
        !hasMessages && createdAt.timeIntervalSinceNow > -86400 // 24 hours
    }

    func otherUserId(currentUserId: UUID) -> UUID {
        currentUserId == user1Id ? user2Id : user1Id
    }
}

// MARK: - Swipe Model

struct Swipe: Codable, Identifiable, Sendable {
    let id: UUID
    let swiperId: UUID
    let swipedId: UUID
    let direction: SwipeDirection
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case swiperId = "swiper_id"
        case swipedId = "swiped_id"
        case direction
        case createdAt = "created_at"
    }
}

enum SwipeDirection: String, Codable, Sendable {
    case like
    case nope
    case superLike = "superLike"

    var icon: String {
        switch self {
        case .like: return "heart.fill"
        case .nope: return "xmark"
        case .superLike: return "star.fill"
        }
    }
}

// MARK: - Mock Data

extension Match {
    static let mock = Match(
        id: UUID(),
        user1Id: UUID(),
        user2Id: UUID(),
        lastMessageAt: Date(),
        lastMessage: "Hey! How are you?",
        createdAt: Date(),
        otherUser: .mock
    )

    static let mockNew = Match(
        id: UUID(),
        user1Id: UUID(),
        user2Id: UUID(),
        lastMessageAt: nil,
        lastMessage: nil,
        createdAt: Date(),
        otherUser: .mock
    )
}
