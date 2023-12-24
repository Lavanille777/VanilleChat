//
//  ChatRequestor.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/20.
//

import Foundation

let kDeafultAPIHost = "api.openai.com"
let kDeafultAPITimeout = 60.0
let kAPIModels = [
    Model.gpt3_5Turbo_1106,
    Model.gpt3_5Turbo,
    Model.gpt3_5Turbo_16k,
    Model.gpt3_5Turbo_16k_0613,
    Model.gpt4_1106_preview,
    Model.gpt4,
    Model.gpt4_32k,
    Model.gpt4_32k_0613,
    "gpt-4-gizmo-g-3w1rEXGE0",
    "gpt-4-all"
]

let kSystemMessageProbability = [
    0.1,
    0.3,
    0.5,
    0.7,
    1.0
]

extension Chat {
    init(fromChatMessage message:ChatMessage) {
        self.init(
            role: message.role,
            content: message.content,
            name: message.name,
            functionCall: message.functionCall
        )
    }
}

enum ChatRequestResult {
    case success(ChatMessage)
    case failed(Error?)
    case finish(ChatMessage)
    case finishWithError(Error)
}

class ChatRequestor: NSObject {
    var timeout: TimeInterval = 60
    var userAvatarUrl = "" //"https://raw.githubusercontent.com/37iOS/iChatGPT/main/icon.png"
    var openAIKey = ""
    var openAI: OpenAI
    var answer = ""
    
    init(openAIKey:String, timeout: TimeInterval = kDeafultAPITimeout, host: String? = kDeafultAPIHost) {
        self.openAIKey = openAIKey
        let config = OpenAI.Configuration(
            token: self.openAIKey,
            host: host ?? kDeafultAPIHost,
            timeoutInterval: timeout
        )
        self.openAI = OpenAI(configuration: config)
    }

    func getUserAvatar() -> String {
        userAvatarUrl
    }

    func sendMessage(
        messages: [ChatMessage],
        model: Model,
        temperature: Double,
        isStreaming: Bool,
        completion: @escaping (ChatRequestResult) -> Void
    ) {
        print("准备发送消息")
        let chatMessages: [Chat] = messages.map { msg in
            print(msg.content)
            return Chat(fromChatMessage: msg)
        }
        
        let query = ChatQuery.init(
            model: model,
            messages: chatMessages,
            responseFormat: ResponseFormat(type: .jsonObject),
            temperature: temperature
        )
        // Chats Streaming
        if isStreaming {
            var chatStreamResult: ChatStreamResult?
            
            var chatMessage: ChatMessage?
            
            var resultContent: String = ""
            openAI.chatsStream(query: query) { partialResult in
                print(partialResult)
                switch partialResult {
                case .success(let chatResult):
                    if var chatMessage, chatResult.id == chatMessage.id {
                        chatMessage = ChatMessage(fromChatStreamResult: chatResult)
                        chatMessage.content = resultContent + chatMessage.content
                        resultContent = ""
                        DispatchQueue.main.async {
                            completion(.success(chatMessage))
                        }
                    } else {
                        chatMessage = ChatMessage(fromChatStreamResult: chatResult)
                        resultContent = chatMessage?.content ?? ""
                    }

                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        completion(.failed(error))
                    }
                }
            } completion: { error in
                if let chatStreamResult, error == nil {
                    completion(.finish(
                        ChatMessage(
                            fromChatStreamResult: self.mergeStreamMessage(
                                with: resultContent, streamResult: chatStreamResult
                            )
                        )
                    ))
                }
                if let error {
                    completion(
                        .finishWithError(error)
                    )
                }
            }
        } else {
            openAI.chats(query: query) { result in
                print(result)
                switch result {
                case .success(let chatResult):
                    let res = chatResult.choices.first?.message.content
                    DispatchQueue.main.async {
                        completion(.success(
                            ChatMessage(fromChatResult: chatResult)
                        ))
                    }
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        completion(.finishWithError(error))
                    }
                }
            }
        }
    }
    
    private func mergeStreamMessage(with content: String, streamResult: ChatStreamResult) -> ChatStreamResult {
        guard let choice = streamResult.choices.first else {
            return streamResult
        }
        
        let delta = ChatStreamResult.Choice.Delta(
            content: content,
            role: choice.delta.role,
            name: choice.delta.name,
            functionCall: choice.delta.functionCall
        )
        
        let mergedChoice = ChatStreamResult.Choice(
            index: choice.index,
            delta: delta,
            finishReason: choice.finishReason
        )

        return ChatStreamResult(
            id: streamResult.id,
            object: streamResult.object,
            created: streamResult.created,
            model: streamResult.model,
            choices: [mergedChoice]
        )
    }
}
