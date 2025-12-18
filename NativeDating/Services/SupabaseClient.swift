import Foundation
import Supabase

/// Configuration for Supabase connection
enum SupabaseConfig {
    // MARK: - Credentials
    // Replace these with your actual Supabase project credentials

    static let url = URL(string: "https://pzfjwdtrzsddyidqxuue.supabase.co")!
    static let anonKey = "sb_publishable_AvSvwg38KkboKHsH5fT5AQ_JTOc8ktU"

    // MARK: - Storage Buckets

    static let avatarsBucket = "avatars"
    static let postImagesBucket = "post-images"
    static let chatImagesBucket = "chat-images"

    // MARK: - Table Names

    enum Tables {
        static let users = "users"
        static let swipes = "swipes"
        static let matches = "matches"
        static let messages = "messages"
        static let posts = "posts"
        static let likes = "likes"
        static let comments = "comments"
        static let blocks = "blocks"
        static let reports = "reports"
        static let interests = "interests"
        static let prompts = "prompts"
    }

    // MARK: - Functions

    enum Functions {
        static let getPotentialMatches = "get_potential_matches"
        static let getNearbyUsers = "get_nearby_users"
    }
}

/// Singleton manager for Supabase client
@Observable
final class SupabaseManager {
    // MARK: - Singleton

    static let shared = SupabaseManager()

    // MARK: - Client

    let client: SupabaseClient

    // MARK: - Initialization

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey,
            options: SupabaseClientOptions(
                auth: .init(
                    flowType: .pkce,
                    storage: KeychainAuthStorage(),
                    autoRefreshToken: true,
                    detectSessionInUrl: true
                ),
                global: .init(
                    headers: [
                        "x-app-version": Constants.appVersion,
                        "x-platform": "ios"
                    ],
                    logger: SupabaseLogger()
                )
            )
        )
    }

    // MARK: - Convenience Accessors

    var auth: AuthClient {
        client.auth
    }

    var database: PostgrestClient {
        client.database
    }

    var storage: SupabaseStorageClient {
        client.storage
    }

    var realtime: RealtimeClientV2 {
        client.realtimeV2
    }

    // MARK: - Table Helpers

    func from(_ table: String) -> PostgrestQueryBuilder {
        database.from(table)
    }

    func rpc(_ function: String, params: some Encodable) async throws -> PostgrestResponse<Void> {
        try await database.rpc(function, params: params).execute()
    }
}

// MARK: - Keychain Auth Storage

/// Secure storage for auth tokens using Keychain
final class KeychainAuthStorage: AuthLocalStorage {
    private let service = "com.nativedating.auth"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    private let userKey = "user"

    func store(key: String, value: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }

    func retrieve(key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.unableToRetrieve
        }
    }

    func remove(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToRemove
        }
    }

    enum KeychainError: Error {
        case unableToStore
        case unableToRetrieve
        case unableToRemove
    }
}

// MARK: - Supabase Logger

/// Custom logger for Supabase operations
final class SupabaseLogger: SupabaseLogger {
    func log(message: SupabaseLogMessage) {
        #if DEBUG
        let level = switch message.level {
        case .verbose: "VERBOSE"
        case .debug: "DEBUG"
        case .warning: "WARNING"
        case .error: "ERROR"
        }
        print("[\(level)] Supabase: \(message.message)")
        #endif
    }
}

// MARK: - Database Extensions

extension PostgrestQueryBuilder {
    /// Select with automatic decoding
    func selectAndDecode<T: Decodable>(_ columns: String = "*", as type: T.Type) async throws -> [T] {
        try await select(columns).execute().value
    }

    /// Select single with automatic decoding
    func selectSingleAndDecode<T: Decodable>(_ columns: String = "*", as type: T.Type) async throws -> T {
        try await select(columns).single().execute().value
    }
}
