//
//  ChatSessionViewModel.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/20.
//

import UIKit

protocol ChatSessionViewModelDelegate: AnyObject {
    func reloadList()
    func reloadLastItem()
    func scrollToBottom(animated: Bool)
}

class ChatSessionViewModel {
    
    weak var delegate: ChatSessionViewModelDelegate?
    
    var config = ChatSessionsManager.shared.currentSessionConfig {
        didSet{
            dataSource = ChatMessagesStorage.shared.loadMessagesFromFile(
                with: config.sessionID
            )
        }
    }
    
    var isAtBottom: Bool = true
    
    var isShowingKeyboard: Bool = false
    
    var lastCellSize: CGSize = .zero
    
    var lastScrollTime: TimeInterval = 0
    
    var dataSource: [ChatMessage] = ChatMessagesStorage.shared.loadMessagesFromFile(
        with: ChatSessionsManager.shared.currentSessionConfig.sessionID
    ) {
        didSet {
            delegate?.reloadList()
        }
    }
    
    var requestor = ChatRequestor(openAIKey: GlobleStateManager.shared.openaiKey)
    
    func sendMessage(content: String){
        
        guard !content.isEmpty else { return }
        
        requestor = ChatRequestor(
            openAIKey: config.apiKey,
            host: config.apiHost
        )
        
        let userMessage = ChatMessage(
            content: content,
            role: .user,
            created: Date().timeIntervalSince1970 * 1000
        )
        
        var messages: [ChatMessage] = []
        
        var systemMessages: [ChatMessage] = []
        config.systemMessages.forEach { message in
            if message.probabilityToUse >= Double.random(in: 0...1) {
                systemMessages.append(message)
            }
        }
        
        messages.append(contentsOf: systemMessages)
        
        if config.compressMemoryEnable && config.compressedMemoryList.count > 0 {
            let compressedHistoryMessage = ChatMessage(
                content: config.compressMemoryMethod,
                role: .system,
                created: Date().timeIntervalSince1970 * 1000,
                model: config.modelType
            )
            messages.append(compressedHistoryMessage)
        }
        
        messages.append(
            contentsOf: dataSource.suffix(config.memoryCount)
        )
        
        messages.append(userMessage)
        dataSource.append(userMessage)
        saveMessagesToFile()
        
        let notificationFBGenerator = UINotificationFeedbackGenerator()
        notificationFBGenerator.notificationOccurred(.success)
        // 准备生成触觉反馈
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
        feedbackGenerator.prepare()
        var lastFeedbackTime = Date().timeIntervalSince1970 * 1000
        
        delegate?.scrollToBottom(animated: true)
        
        requestor.sendMessage(
            messages: messages,
            model: config.modelType,
            temperature: config.temperature,
            isStreaming: true,
            completion: { [weak self] result in
                switch result {
                case .success(let message) :
                    guard let self else { return }
                    if let last = dataSource.last{
                        if message.id != last.id {
                            dataSource.append(message)
                        } else {
                            let newMessage = message
                            newMessage.content = dataSource[
                                dataSource.count - 1
                            ].content + message.content
                            newMessage.created = Date().timeIntervalSince1970 * 1000
                            dataSource[
                                dataSource.count - 1
                            ] = newMessage
                        }
                        let now = Date().timeIntervalSince1970 * 1000
                        if isAtBottom && now - lastScrollTime > 100 {
                            lastScrollTime = now
                            delegate?.scrollToBottom(animated: true)
                        }
                        saveMessagesToFile()
                        
                        if now - lastFeedbackTime > 500 {
                            lastFeedbackTime = now
                            feedbackGenerator.impactOccurred()
                            feedbackGenerator.prepare()
                        }
                    }
                    if !message.finishReason.isEmpty {
                        lastCellSize = .zero
                        compressHistory()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            let successFB = UINotificationFeedbackGenerator()
                            successFB.notificationOccurred(.success)
                        }
                    }
                case .failed(let error) :
                    if let error {
                        print(error)
                    }
                case .finish(let message) :
                    break
                case .finishWithError(let error):
                    print(error)
                }
            }
        )
    }
    
    func saveMessagesToFile() {
        ChatMessagesStorage.shared.saveMessagesToFile(
            with: config.sessionID,
            chatMessages: dataSource
        )
    }
    

    func compressHistory() {
        
        if config.compressMemoryEnable && dataSource.count > config.memoryCount + 1  {
            print("开始压缩历史消息")
            let systemMessage = ChatMessage(
                content: "需要你压缩一些消息，以下是关于压缩的提示，不要将提示内容带入压缩结果，{" + config.compressMemoryMethod + "}, 以下是需要你压缩的消息：",
                role: .system
            )
            
            guard let originalMsg = dataSource.prefix(
                dataSource.count - config.memoryCount
            ).last(where: {$0.role == .assistant}) else {
                print("无消息可压缩")
                return
            }
            
            requestor.sendMessage(
                messages: [
                    systemMessage, originalMsg
                ],
                model: Model.gpt3_5Turbo_1106,
                temperature: 0.5,
                isStreaming: false,
                completion: { result in
                    switch result {
                    case .success(let chatMessage) :
                        print("压缩完成：\(chatMessage.content)")
                        DispatchQueue.main.async { [weak self] in
                            guard let self else { return }
                            var syncMessage = chatMessage
                            syncMessage.created = originalMsg.created
                            config.compressedMemoryList.append(syncMessage)
                            if config.compressedMemoryList.count > config.compressMemoryCount {
                                config.compressedMemoryList.removeFirst()
                            }
                        }
                    case .failed(let error) :
                        if let error {
                            print(error)
                        }
                    case .finish(let result) : break
                    case .finishWithError(let error):
                        print(error)
                    }
                }
            )
        }
    }

    
}
