//
//  ChatGlobleConfigManager.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/24.
//

import Foundation

class ChatGlobleConfigManager {
    
    public static let shared = ChatGlobleConfigManager()
    
    var config: ChatGlobleConfig = ChatGlobleConfigManager.loadChatGlobleConfigFromFile()
    
    var queue = DispatchConcurrentQueue(label: "ChatGlobleConfigManagerQueue")

    class func loadChatGlobleConfigFromFile() -> ChatGlobleConfig {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "ChatGlobleConfigManager") {
            if let decodedData = try? JSONDecoder().decode(ChatGlobleConfig.self, from: data) {
                return decodedData
            }
        }
        return ChatGlobleConfig()
    }
    
    class func saveChatGlobleConfigToFile() {
        ChatGlobleConfigManager.shared.queue.sync {
            let userDefaults = UserDefaults.standard
            do {
                let encodedData = try JSONEncoder().encode(ChatGlobleConfigManager.shared.config)
                userDefaults.set(encodedData, forKey: "ChatGlobleConfigManager")
            } catch {
                print("Failed to encode chat rooms: \(error)")
            }
        }
    }
    
}


@propertyWrapper
class AutoSaveGlobleConfig<T: Codable>: Codable, ObservableObject {
    var parent: SessionConfigBox<ChatGlobleConfig>
    var defaultValue: T
    var wrappedValue: T {
        get {
            defaultValue
        }
        set {
            defaultValue = newValue
            parent.session?.objectWillChange.send()
            ChatGlobleConfigManager.saveChatGlobleConfigToFile()
        }
    }
    
    init(defaultValue: T, parent: SessionConfigBox<ChatGlobleConfig>) {
        self.defaultValue = defaultValue
        self.parent = parent
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<AutoSaveGlobleConfig<T>.CodingKeys> = encoder.container(keyedBy: AutoSaveGlobleConfig<T>.CodingKeys.self)
        try container.encode(self.defaultValue, forKey: AutoSaveGlobleConfig<T>.CodingKeys.defaultValue)
    }
    
    enum CodingKeys: CodingKey {
        case parent
        case defaultValue
    }
    
    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<AutoSaveGlobleConfig<T>.CodingKeys> = try decoder.container(keyedBy: AutoSaveGlobleConfig<T>.CodingKeys.self)
        self.parent = SessionConfigBox()
        self.defaultValue = try container.decode(T.self, forKey: AutoSaveGlobleConfig<T>.CodingKeys.defaultValue)
    }
}

class ChatGlobleConfig: Codable, ObservableObject {
    @AutoSaveGlobleConfig
    var apiKeys: [String]
    @AutoSaveGlobleConfig
    var apiHosts: [String]
    
    
    init(
        apiKeys: [String] = [],
        apiHosts: [String] = []
    ) {
        let weakSelf: SessionConfigBox<ChatGlobleConfig> = SessionConfigBox()
        _apiKeys = .init(defaultValue: apiKeys, parent: weakSelf)
        _apiHosts = .init(defaultValue: apiHosts, parent: weakSelf)
        weakSelf.session = self
    }
    
    required init(from decoder: Decoder) throws {
        let weakSelf: SessionConfigBox<ChatGlobleConfig> = SessionConfigBox()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._apiKeys = try container.decode(AutoSaveGlobleConfig<[String]>.self, forKey: .apiKeys, mySelf: weakSelf)
        self._apiHosts = try container.decode(AutoSaveGlobleConfig<[String]>.self, forKey: .apiHosts, mySelf: weakSelf)
        weakSelf.session = self
    }
}
extension KeyedDecodingContainer {
    func decode<T>(_ type: AutoSaveGlobleConfig<T>.Type, forKey key: KeyedDecodingContainer<K>.Key, mySelf: SessionConfigBox<ChatGlobleConfig>) throws -> AutoSaveGlobleConfig<T> where AutoSaveGlobleConfig<T> : Decodable {
        let data = try decode(type, forKey: key)
        data.parent = mySelf
        return data
    }
}
