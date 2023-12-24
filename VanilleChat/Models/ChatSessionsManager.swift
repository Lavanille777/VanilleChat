//
//  ChatSessionsManager.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/21.
//

import Foundation

class ChatSessionsManager {
    public static let shared = ChatSessionsManager()
    
    static var chatSessionConfigs: [ChatSessionConfig] = [] {
        didSet {
            ChatSessionsConfigStorage.shared.saveChatSessionConfigToFile()
        }
    }
    
    var currentSessionConfig = ChatSessionsManager.loadLatestSessionConfig()
    
    var currentSessionViewMode: ChatSessionViewModel?
    
    class func loadLatestSessionConfig() -> ChatSessionConfig {
        if ChatSessionsConfigStorage.shared.loadChatSessionConfigFromFile(),
           let chatSessionConfig = ChatSessionsManager.chatSessionConfigs.last
        {
            return chatSessionConfig
        }
        let chatSessionConfig = ChatSessionConfig()
        ChatSessionsManager.chatSessionConfigs.append(chatSessionConfig)
        return chatSessionConfig
    }
}
