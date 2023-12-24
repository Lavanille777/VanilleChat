//
//  ChatMessage.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/20.
//

import Foundation

class ChatMessage: Codable {
    var id: String {
        get{
            _id.isEmpty ? "\(created)" : _id
        }
        set {
            _id = newValue
        }
    }
    var content: String
    let role: Chat.Role
    let name: String?
    let functionCall: ChatFunctionCall?
    let finishReason: String
    let object: String
    var created: TimeInterval
    let model: Model
    let usage: ChatResult.Usage?
    var probabilityToUse: Double = 1
    
    private var _id: String = ""
    
    init(
        content: String = "",
        role: Chat.Role = .user,
        name: String? = nil,
        functionCall: ChatFunctionCall? = nil,
        finishReason: String = "",
        id: String = "",
        object: String = "",
        created: TimeInterval = 0,
        model: Model = Model.gpt3_5Turbo_1106,
        usage: ChatResult.Usage? = nil,
        probabilityToUse: Double = 1
    ) {
        self.content = content
        self.role = role
        self.name = name
        self.functionCall = functionCall
        self.finishReason = finishReason
        self._id = id
        self.object = object
        self.created = created
        self.model = model
        self.usage = usage
    }
    
    init(fromChatStreamResult result: ChatStreamResult) {
        self.finishReason = result.choices.first?.finishReason ?? ""
        self.content = result.choices.first?.delta.content ?? ""
        self.functionCall = result.choices.first?.delta.functionCall
        self.name = result.choices.first?.delta.name
        self.role = result.choices.first?.delta.role ?? .assistant
        self._id = result.id
        self.created = result.created
        self.model = result.model
        self.object = result.object
        self.usage = nil
    }
    
    init(fromChatResult result: ChatResult) {
        self.finishReason = result.choices.first?.finishReason ?? ""
        self.content = result.choices.first?.message.content ?? ""
        self.functionCall = result.choices.first?.message.functionCall
        self.name = result.choices.first?.message.name
        self.role = result.choices.first?.message.role ?? .assistant
        self._id = result.id
        self.created = result.created
        self.model = result.model
        self.object = result.object
        self.usage = result.usage
    }
}

