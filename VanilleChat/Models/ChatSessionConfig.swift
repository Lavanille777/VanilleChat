//
//  ChatSessionConfig.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/20.
//

import Foundation
import Observation

class SessionConfigBox<T: Codable>: Codable {
    var session: T?
}

@propertyWrapper
class AutoSaveConfig<T: Codable>: Codable, ObservableObject {
    var parent: SessionConfigBox<ChatSessionConfig>
    var defaultValue: T
    var wrappedValue: T {
        get {
            defaultValue
        }
        set {
            defaultValue = newValue
            parent.session?.objectWillChange.send()
            ChatSessionsConfigStorage.shared.saveChatSessionConfigToFile()
        }
    }
    
    init(defaultValue: T, parent: SessionConfigBox<ChatSessionConfig>) {
        self.defaultValue = defaultValue
        self.parent = parent
    }
    
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<AutoSaveConfig<T>.CodingKeys> = encoder.container(keyedBy: AutoSaveConfig<T>.CodingKeys.self)
        try container.encode(self.defaultValue, forKey: AutoSaveConfig<T>.CodingKeys.defaultValue)
    }
    
    enum CodingKeys: CodingKey {
        case parent
        case defaultValue
    }
    
    required init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<AutoSaveConfig<T>.CodingKeys> = try decoder.container(keyedBy: AutoSaveConfig<T>.CodingKeys.self)
        self.parent = SessionConfigBox()
        self.defaultValue = try container.decode(T.self, forKey: AutoSaveConfig<T>.CodingKeys.defaultValue)
    }
}

class ChatSessionConfig: Codable, ObservableObject {
    @AutoSaveConfig
    var sessionID: String
    @AutoSaveConfig
    var sessionName: String
    @AutoSaveConfig
    var systemMessages: [ChatMessage]
    @AutoSaveConfig
    var temperature: Double
    @AutoSaveConfig
    var memoryCount: Int
    @AutoSaveConfig
    var memoryEnable: Bool
    @AutoSaveConfig
    var compressMemoryCount: Int
    @AutoSaveConfig
    var compressMemoryEnable: Bool
    @AutoSaveConfig
    var compressMemoryMethod: String
    var compressedMemory: String {
        get {
            var content = "以下是历史消息的总结"
            compressedMemoryList
                .filter({!$0.content.isEmpty}).forEach { msg in
                content += ";" + msg.content
            }
            return content == "以下是历史消息的总结" ? "无压缩历史消息" : content
        }
    }
    @AutoSaveConfig
    var compressedMemoryList: [ChatMessage]
    @AutoSaveConfig
    var modelType: Model
    @AutoSaveConfig
    var apiKey: String
    @AutoSaveConfig
    var apiHost: String
    
    init(
        sessionName: String = "新的对话",
        systemMessages: [ChatMessage] = [],
        temperature: Double = 0.7,
        memoryCount: Int = 3,
        memoryEnable: Bool = true,
        compressMemoryCount: Int = 8,
        compressMemoryEnable: Bool = true,
        compressMemoryMethod: String = "尽量精炼你收到的消息",
        compressedMemoryList: [ChatMessage] = [],
        modelType: Model = .gpt3_5Turbo_1106,
        apiKey: String = ChatGlobleConfigManager.shared.config.apiKeys.first ?? "",
        apiHost: String = ChatGlobleConfigManager.shared.config.apiHosts.first ?? ""
    ) {
        let weakSelf: SessionConfigBox<ChatSessionConfig> = SessionConfigBox()
        _sessionID = .init(defaultValue: "\(Date().timeIntervalSince1970 * 1000)", parent: weakSelf)
        _systemMessages = .init(defaultValue: systemMessages, parent: weakSelf)
        _sessionName = .init(defaultValue: sessionName, parent: weakSelf)
        _temperature = .init(defaultValue: temperature, parent: weakSelf)
        _memoryCount = .init(defaultValue: memoryCount, parent: weakSelf)
        _memoryEnable = .init(defaultValue: memoryEnable, parent: weakSelf)
        _compressMemoryCount = .init(defaultValue: compressMemoryCount, parent: weakSelf)
        _compressMemoryEnable = .init(defaultValue: compressMemoryEnable, parent: weakSelf)
        _compressMemoryMethod = .init(defaultValue: compressMemoryMethod, parent: weakSelf)
        _compressedMemoryList = .init(defaultValue: compressedMemoryList, parent: weakSelf)
        _modelType = .init(defaultValue: modelType, parent: weakSelf)
        let apiKey = apiKey.isEmpty ? ChatGlobleConfigManager.shared.config.apiKeys.first ?? "" : apiKey
        _apiKey = .init(defaultValue: apiKey, parent: weakSelf)
        let apiHost = apiHost.isEmpty ? ChatGlobleConfigManager.shared.config.apiHosts.first ?? "" : apiHost
        _apiHost = .init(defaultValue: apiHost, parent: weakSelf)
        weakSelf.session = self
    }
    
    required init(from decoder: Decoder) throws {
        let weakSelf: SessionConfigBox<ChatSessionConfig> = SessionConfigBox()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._sessionID = try container.decode(AutoSaveConfig<String>.self, forKey: .sessionID, mySelf: weakSelf)
        self._sessionName = try container.decode(AutoSaveConfig<String>.self, forKey: .sessionName, mySelf: weakSelf)
        self._systemMessages = try container.decode(AutoSaveConfig<[ChatMessage]>.self, forKey: .systemMessages, mySelf: weakSelf)
        self._temperature = try container.decode(AutoSaveConfig<Double>.self, forKey: .temperature, mySelf: weakSelf)
        self._memoryCount = try container.decode(AutoSaveConfig<Int>.self, forKey: .memoryCount, mySelf: weakSelf)
        self._memoryEnable = try container.decode(AutoSaveConfig<Bool>.self, forKey: .memoryEnable, mySelf: weakSelf)
        self._compressMemoryCount = try container.decode(AutoSaveConfig<Int>.self, forKey: .compressMemoryCount, mySelf: weakSelf)
        self._compressMemoryEnable = try container.decode(AutoSaveConfig<Bool>.self, forKey: .compressMemoryEnable, mySelf: weakSelf)
        self._compressMemoryMethod = try container.decode(AutoSaveConfig<String>.self, forKey: .compressMemoryMethod, mySelf: weakSelf)
        self._compressedMemoryList = try container.decode(AutoSaveConfig<[ChatMessage]>.self, forKey: .compressedMemoryList, mySelf: weakSelf)
        self._modelType = try container.decode(AutoSaveConfig<Model>.self, forKey: .modelType, mySelf: weakSelf)
        self._apiKey = try container.decode(AutoSaveConfig<String>.self, forKey: .apiKey, mySelf: weakSelf)
        self._apiHost = try container.decode(AutoSaveConfig<String>.self, forKey: .apiHost, mySelf: weakSelf)
        
        if self.apiKey.isEmpty {
            let apiKey = apiKey.isEmpty ? ChatGlobleConfigManager.shared.config.apiKeys.first ?? "" : apiKey
            self._apiKey = .init(defaultValue: apiKey, parent: weakSelf)
        }
        if self.apiHost.isEmpty {
            let apiHost = apiHost.isEmpty ? ChatGlobleConfigManager.shared.config.apiHosts.first ?? "" : apiHost
            self._apiHost = .init(defaultValue: apiHost, parent: weakSelf)
        }
        
        weakSelf.session = self
    }
}
extension KeyedDecodingContainer {
    func decode<T>(_ type: AutoSaveConfig<T>.Type, forKey key: KeyedDecodingContainer<K>.Key, mySelf: SessionConfigBox<ChatSessionConfig>) throws -> AutoSaveConfig<T> where AutoSaveConfig<T> : Decodable {
        let data = try decode(type, forKey: key)
        data.parent = mySelf
        return data
    }
}
