import Foundation

// MARK: - Message Model

struct Message: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let matchId: UUID
    let senderId: UUID
    var content: String
    var imageURL: String?
    var isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case senderId = "sender_id"
        case content
        case imageURL = "image_url"
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    // MARK: - Computed Properties

    var hasImage: Bool {
        imageURL != nil
    }

    func isFromCurrentUser(_ currentUserId: UUID) -> Bool {
        senderId == currentUserId
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(createdAt) {
            formatter.dateFormat = "h:mm a"
        } else if Calendar.current.isDateInYesterday(createdAt) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: createdAt)
    }
}

// MARK: - Message Group (for date headers)

struct MessageGroup: Identifiable {
    let id: Date
    let date: Date
    var messages: [Message]

    var dateHeader: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEEE"
        } else if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MMMM d"
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
        }
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    let matchId: UUID
    let timestamp: Date

    var isExpired: Bool {
        timestamp.timeIntervalSinceNow < -Constants.typingIndicatorTimeout
    }
}

// MARK: - Mock Data

extension Message {
    static let mock = Message(
        id: UUID(),
        matchId: UUID(),
        senderId: UUID(),
        content: "Hey! How's it going?",
        imageURL: nil,
        isRead: true,
        createdAt: Date()
    )

    static let mockReceived = Message(
        id: UUID(),
        matchId: UUID(),
        senderId: UUID(),
        content: "I'm doing great! Just got back from a hike. The weather was perfect!",
        imageURL: nil,
        isRead: true,
        createdAt: Date().addingTimeInterval(-300)
    )

    static let mockWithImage = Message(
        id: UUID(),
        matchId: UUID(),
        senderId: UUID(),
        content: "Check out this view!",
        imageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4",
        isRead: false,
        createdAt: Date().addingTimeInterval(-600)
    )
}

// MARK: - Message Helpers

extension Array where Element == Message {
    /// Groups messages by date
    func groupedByDate() -> [MessageGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: self) { message in
            calendar.startOfDay(for: message.createdAt)
        }
        return grouped.map { date, messages in
            MessageGroup(id: date, date: date, messages: messages.sorted { $0.createdAt < $1.createdAt })
        }.sorted { $0.date < $1.date }
    }
}
