//
//  ChatSessionsStorage.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/21.
//

import Foundation

class ChatSessionsConfigStorage {
    
    public static let shared = ChatSessionsConfigStorage()
    
    var queue = DispatchConcurrentQueue(label: "ChatSessionsConfigStorageQueue")

    func loadChatSessionConfigFromFile() -> Bool {
        let userDefaults = UserDefaults.standard
        if let data = userDefaults.data(forKey: "ChatSessionsConfigStorage") {
            if let decodedData = try? JSONDecoder().decode([ChatSessionConfig].self, from: data) {
                ChatSessionsManager.chatSessionConfigs = decodedData
                return true
            }
        }
        return false
    }
    
    func saveChatSessionConfigToFile() {
        guard !ChatSessionsManager.chatSessionConfigs.isEmpty else { return }
        queue.sync {
            let userDefaults = UserDefaults.standard
            do {
                let encodedData = try JSONEncoder().encode(ChatSessionsManager.chatSessionConfigs)
                userDefaults.set(encodedData, forKey: "ChatSessionsConfigStorage")
            } catch {
                print("Failed to encode chat rooms: \(error)")
            }
        }
    }
    
}
