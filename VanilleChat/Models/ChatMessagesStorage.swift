//
//  ChatMessagesStorage.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/21.
//

import Foundation

class ChatMessagesStorage {
    
    public static let shared = ChatMessagesStorage()
    
    private let fileManager = MessageFileManager()
    
    private var curSessionID: String = ""
    
    func loadMessagesFromFile(with sessionID: String) -> [ChatMessage] {
        var chatMessages: [ChatMessage] = []
        do {
            let url = try getDocumentsDirectory().appendingPathComponent("message_\(sessionID).json")
            let data = try Data(contentsOf: url)
            chatMessages = try JSONDecoder().decode([ChatMessage].self, from: data)
        } catch {
            print("Error loading messages: \(error.localizedDescription)")
        }
        return chatMessages
    }
    
    func saveMessagesToFile(with sessionID: String, chatMessages: [ChatMessage]) {
        guard !sessionID.isEmpty else { return }
        do {
            let url = try getDocumentsDirectory().appendingPathComponent("message_\(sessionID).json")
            let data = try JSONEncoder().encode(chatMessages)
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
            self.curSessionID = sessionID
        } catch {
            print("Error saving messages: \(error.localizedDescription)")
        }
    }
    
    func deleteMessagesAtFile(with sessionID: String) {
        do {
            let url = try getDocumentsDirectory().appendingPathComponent("\(sessionID).json")
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error saving messages: \(error.localizedDescription)")
        }
    }
    
//    func lastMessage(_ roomID: String) -> ChatMessage? {
//        return messages(forRoom: roomID).last
//    }
//    
//    func messages(forRoom roomID: String) -> [ChatMessage] {
//        let messages = fileManager.loadMessages(forRoom: roomID)
//        self.messages = messages
//        updateMessages(roomID: roomID, chats: messages)
//        return messages
//    }
//    
//    func addMessage(roomID: String, chat: ChatMessage) {
//        var messages = fileManager.loadMessages(forRoom: roomID)
//        messages.append(chat)
//        fileManager.saveMessages(messages, forRoom: roomID)
//    }
//    
//    func updateMessages(roomID: String, chats: [ChatMessage]) {
//        fileManager.saveMessages(chats, forRoom: roomID)
//    }
//
//    func updateMessages(roomID: String, chats: [ChatMessage]) {
//        fileManager.saveMessages(chats, forRoom: roomID)
//    }
//
    func deleteMessages(with id: String, roomID: String) {
        fileManager.deleteMessages(with: id, forRoom: roomID)
    }
    
    private func getDocumentsDirectory() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}

// MARK: - MessageFileManager
class MessageFileManager {
    func saveMessages(_ messages: [ChatMessage], forRoom roomID: String) {
        do {
            print("======messages saved====== roomID: \(roomID) count: \(messages.count)")
            let url = try getDocumentsDirectory().appendingPathComponent("\(roomID).json")
            let data = try JSONEncoder().encode(messages)
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Error saving messages: \(error.localizedDescription)")
        }
    }
    
    func deleteMessages(with id: String, forRoom roomID: String) {
        var conversationMessages = loadMessages(forRoom: roomID)
        conversationMessages.removeAll { $0.id == id }
        saveMessages(conversationMessages, forRoom: roomID)
    }
    
    func loadMessages(forRoom roomID: String) -> [ChatMessage] {
        do {
            let url = try getDocumentsDirectory().appendingPathComponent("\(roomID).json")
            let data = try Data(contentsOf: url)
            let messages = try JSONDecoder().decode([ChatMessage].self, from: data)
            print("======messages loaded====== roomID: \(roomID) count: \(messages.count)")
            return messages
        } catch {
            print("Error loading messages: \(error.localizedDescription)")
            return []
        }
    }
    
    private func getDocumentsDirectory() throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}
