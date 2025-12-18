import Foundation

// MARK: - User Model

struct User: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var email: String
    var phone: String?

    // Basic Info
    var displayName: String
    var birthDate: Date
    var gender: Gender
    var genderPreference: [Gender]
    var bio: String?

    // Location
    var latitude: Double?
    var longitude: Double?
    var city: String?
    var country: String?

    // Details
    var heightCm: Int?
    var jobTitle: String?
    var company: String?
    var education: String?
    var lifestyle: LifestylePreferences?

    // Media & Content
    var photoURLs: [String]
    var interests: [String]
    var prompts: [PromptAnswer]

    // Status
    var isVerified: Bool
    var isPremium: Bool
    var lastActive: Date
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Computed Properties

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var primaryPhotoURL: URL? {
        photoURLs.first.flatMap { URL(string: $0) }
    }

    var formattedHeight: String? {
        guard let cm = heightCm else { return nil }
        let feet = cm / 30.48
        let inches = Int((feet - Double(Int(feet))) * 12)
        return "\(Int(feet))'\(inches)\""
    }

    var locationString: String? {
        [city, country].compactMap { $0 }.joined(separator: ", ")
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case displayName = "display_name"
        case birthDate = "birth_date"
        case gender
        case genderPreference = "gender_preference"
        case bio
        case latitude, longitude, city, country
        case heightCm = "height_cm"
        case jobTitle = "job_title"
        case company, education, lifestyle
        case photoURLs = "photo_urls"
        case interests, prompts
        case isVerified = "is_verified"
        case isPremium = "is_premium"
        case lastActive = "last_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Gender

enum Gender: String, Codable, CaseIterable, Identifiable, Sendable {
    case man
    case woman
    case nonBinary = "nonBinary"
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .man: return "Man"
        case .woman: return "Woman"
        case .nonBinary: return "Non-binary"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .man: return "person.fill"
        case .woman: return "person.fill"
        case .nonBinary: return "person.2.fill"
        case .other: return "person.fill.questionmark"
        }
    }
}

// MARK: - Lifestyle Preferences

struct LifestylePreferences: Codable, Hashable, Sendable {
    var drinking: LifestyleOption?
    var smoking: LifestyleOption?
    var exercise: LifestyleOption?
    var diet: DietOption?
    var children: ChildrenOption?
    var religion: String?
    var politics: String?
}

enum LifestyleOption: String, Codable, CaseIterable, Identifiable, Sendable {
    case never
    case sometimes
    case often

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .never: return "Never"
        case .sometimes: return "Sometimes"
        case .often: return "Often"
        }
    }
}

enum DietOption: String, Codable, CaseIterable, Identifiable, Sendable {
    case omnivore
    case vegetarian
    case vegan
    case pescatarian
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .omnivore: return "Omnivore"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .pescatarian: return "Pescatarian"
        case .other: return "Other"
        }
    }
}

enum ChildrenOption: String, Codable, CaseIterable, Identifiable, Sendable {
    case dontHave = "dont_have"
    case have
    case wantSomeday = "want_someday"
    case dontWant = "dont_want"
    case notSure = "not_sure"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dontHave: return "Don't have children"
        case .have: return "Have children"
        case .wantSomeday: return "Want someday"
        case .dontWant: return "Don't want"
        case .notSure: return "Not sure yet"
        }
    }
}

// MARK: - Prompt Answer

struct PromptAnswer: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var promptId: String
    var promptText: String
    var answer: String

    init(id: UUID = UUID(), promptId: String, promptText: String, answer: String) {
        self.id = id
        self.promptId = promptId
        self.promptText = promptText
        self.answer = answer
    }

    enum CodingKeys: String, CodingKey {
        case id
        case promptId = "prompt_id"
        case promptText = "prompt_text"
        case answer
    }
}

// MARK: - Prompt Templates

enum PromptTemplate: String, CaseIterable, Identifiable {
    case idealWeekend = "ideal_weekend"
    case lookingFor = "looking_for"
    case funFact = "fun_fact"
    case dealbreaker = "dealbreaker"
    case perfectDate = "perfect_date"
    case passions = "passions"
    case unpopularOpinion = "unpopular_opinion"
    case bucketList = "bucket_list"
    case favoriteMemory = "favorite_memory"
    case askMeAbout = "ask_me_about"

    var id: String { rawValue }

    var text: String {
        switch self {
        case .idealWeekend: return "My ideal weekend..."
        case .lookingFor: return "I'm looking for..."
        case .funFact: return "A fun fact about me..."
        case .dealbreaker: return "My biggest dealbreaker..."
        case .perfectDate: return "My perfect first date..."
        case .passions: return "I'm passionate about..."
        case .unpopularOpinion: return "My unpopular opinion..."
        case .bucketList: return "On my bucket list..."
        case .favoriteMemory: return "My favorite memory..."
        case .askMeAbout: return "Ask me about..."
        }
    }
}

// MARK: - Interest

struct Interest: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var name: String
    var category: String
    var icon: String?

    static let categories = [
        "Music", "Sports", "Food & Drink", "Arts", "Outdoors",
        "Gaming", "Travel", "Fitness", "Movies & TV", "Books",
        "Technology", "Fashion", "Pets", "Wellness", "Social"
    ]
}

// MARK: - User Extensions

extension User {
    /// Creates a new user for signup
    static func new(
        id: UUID,
        email: String,
        displayName: String,
        birthDate: Date,
        gender: Gender
    ) -> User {
        User(
            id: id,
            email: email,
            phone: nil,
            displayName: displayName,
            birthDate: birthDate,
            gender: gender,
            genderPreference: [],
            bio: nil,
            latitude: nil,
            longitude: nil,
            city: nil,
            country: nil,
            heightCm: nil,
            jobTitle: nil,
            company: nil,
            education: nil,
            lifestyle: nil,
            photoURLs: [],
            interests: [],
            prompts: [],
            isVerified: false,
            isPremium: false,
            lastActive: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    /// Mock user for previews
    static let mock = User(
        id: UUID(),
        email: "jane@example.com",
        phone: nil,
        displayName: "Jane",
        birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!,
        gender: .woman,
        genderPreference: [.man],
        bio: "Coffee enthusiast. Dog lover. Always up for an adventure.",
        latitude: 40.7128,
        longitude: -74.0060,
        city: "New York",
        country: "USA",
        heightCm: 168,
        jobTitle: "Product Designer",
        company: "Tech Co",
        education: "NYU",
        lifestyle: LifestylePreferences(
            drinking: .sometimes,
            smoking: .never,
            exercise: .often,
            diet: .omnivore,
            children: .dontHave
        ),
        photoURLs: [
            "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
            "https://images.unsplash.com/photo-1524504388940-b1c1722653e1"
        ],
        interests: ["Coffee", "Hiking", "Photography", "Travel", "Dogs"],
        prompts: [
            PromptAnswer(
                promptId: "ideal_weekend",
                promptText: "My ideal weekend...",
                answer: "Brunch with friends, exploring a new neighborhood, and ending with a good book."
            ),
            PromptAnswer(
                promptId: "looking_for",
                promptText: "I'm looking for...",
                answer: "Someone who can make me laugh and isn't afraid of spontaneous adventures."
            )
        ],
        isVerified: true,
        isPremium: false,
        lastActive: Date(),
        createdAt: Date(),
        updatedAt: Date()
    )
}
