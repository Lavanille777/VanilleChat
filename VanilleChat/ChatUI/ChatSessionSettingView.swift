//
//  ChatSessionSettingView.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/20.
//

import SwiftUI

extension Int {
    var doubleValue: Double{
        get {
            Double(self)
        }
        set {
            self = Int(newValue)
        }
    }
}

struct ChatSessionSettingView: View {
    
    @EnvironmentObject var config: ChatSessionConfig
    
    var body: some View {
        List {
            Section {
                ConfigCellView(
                    type: .textFiled(value: $config.sessionName, placeholder: "请输入标题")
                )
            } header: {
                Text("设置你的对话标题")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            Section {
                if config.systemMessages.count > 0 {
                    ForEach(config.systemMessages.indices, id: \.self) { index in
                        HStack() {
                            getProbabilityPicker(with: index)
                        }.swipeActions {
                            Button {
                                config.systemMessages.remove(at: index)
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }.animation(.easeInOut, value: $config.systemMessages.count)
                }
                
                
                Button {
                    var systemMessages = config.systemMessages
                    systemMessages.append(
                        ChatMessage(
                            content: "",
                            role: .system,
                            created: Date().timeIntervalSince1970,
                            probabilityToUse: 1
                        )
                    )
                    config.systemMessages = systemMessages
                } label: {
                    HStack {
                        Spacer()
                        Text("添加一条")
                        Spacer()
                    }
                }
            } header: {
                Text("设置你的系统提示")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            Section {
                ConfigCellView(
                    type: .slider(value: $config.temperature, range: 0...1, step: 0.1, precision: 1)
                )
            } header: {
                Text("设置你的对话标题")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            Section {
                ConfigCellView(
                    type: .slider(value: $config.memoryCount.doubleValue, range: 0...64, step: 1.0, precision: 0)
                )
            } header: {
                Text("设置你的对话标题")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            Section {
                VStack {
                    Toggle(isOn: $config.compressMemoryEnable) {
                        Text("启用历史消息压缩")
                    }
                    HStack {
                        Slider(value: $config.compressMemoryCount.doubleValue, in: 5...50, step: 1.0) {
                            Text("aVfdfalue")
                        } onEditingChanged: { _ in
                            
                        }
                        Text(String(format: "%d", config.compressMemoryCount))
                    }
                    Text("")
                }
            } header: {
                Text("设置你的对话标题")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            Section {
                ConfigCellView(
                    type: .textFiled(value: $config.sessionName, placeholder: "请输入标题")
                )
            } header: {
                Text("设置你的对话标题")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            if config.compressMemoryEnable {
                Section {
                    ConfigCellView(
                        type: .textEditor(
                            value: $config.compressMemoryMethod,
                            placeholder: ""
                        )
                    )
                } header: {
                    Text("设置你的对话标题")
                } footer: {
                    Text("对话顶部展示的名称")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        Text(config.compressedMemory)
                            .foregroundStyle(Color.secondary)
                            .font(.footnote)
                    }
                } header: {
                    Text("设置你的对话标题")
                } footer: {
                    Text("对话顶部展示的名称")
                }
            }
            
            Section {
                Picker(selection: $config.modelType, label: Text("选择模型")) {
                    ForEach(0..<kAPIModels.count, id: \.self) {
                        Text(kAPIModels[$0]).tag(kAPIModels[$0])
                    }
                }
            } header: {
                Text("设置你的对话标题")
            } footer: {
                Text("对话顶部展示的名称")
            }
            
            
            if !ChatGlobleConfigManager.shared.config.apiKeys.isEmpty && !ChatGlobleConfigManager.shared.config.apiHosts.isEmpty {
                Section {
                    VStack {
                        Picker("Key", selection: $config.apiKey) {
                            ForEach(0..<ChatGlobleConfigManager.shared.config.apiKeys.count, id: \.self) {
                                Text(
                                    ChatGlobleConfigManager.shared.config.apiKeys[$0]
                                )
                                .tag(ChatGlobleConfigManager.shared.config.apiKeys[$0])
                            }
                        }
                        Divider()
                        Picker("Host", selection: $config.apiHost) {
                            ForEach(0..<ChatGlobleConfigManager.shared.config.apiHosts.count, id: \.self) {
                                Text(
                                    ChatGlobleConfigManager.shared.config.apiHosts[$0]
                                )
                                .tag(ChatGlobleConfigManager.shared.config.apiHosts[$0])
                            }
                        }
                    }
                    
                } header: {
                    Text("设置你的API")
                }
            }
            

            
        }
        
    }
    
    func getProbabilityPicker(with index: Int) -> some View {
        Picker(
            selection: $config.systemMessages[index].probabilityToUse,
            label:
                ConfigCellView(
                    type: .textEditor(
                        value: $config.systemMessages[index].content,
                        placeholder: "请输入提示词"
                    )
                )
        ) {
            ForEach(0..<kSystemMessageProbability.count, id: \.self) {
                Text(
                    String(
                        format: "%.1f",
                        kSystemMessageProbability[$0]
                    )
                )
                .tag(kSystemMessageProbability[$0])
            }
        }
    }
    
}

enum ConfigCellType {
    case textFiled(
        value: Binding<String>,
        placeholder: String
    )
    case textEditor(
        value: Binding<String>,
        placeholder: String
    )
    case slider(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        precision: Int
    )
}

extension String {
    var doubleValue: Double {
        get {
            Double(self) ?? 0
        }
        set {
            self = String(newValue)
        }
    }
}

struct ConfigCellView: View {
    let type: ConfigCellType
    
    var body: some View {
        VStack(alignment: .leading) {
            switch type {
            case .textFiled(let value, let placeholder):
                TextField(
                    placeholder,
                    text: value
                )
                .keyboardType(.default)
                .scrollContentBackground(.hidden)
                .disableAutocorrection(true)
            case .slider(let value, let range, let step, let precision):
                HStack {
                    Slider(value: value, in: range, step: step) {
                        Text("aVfdfalue")
                    } onEditingChanged: { _ in
                        
                    }
                    Text(String(format: "%.\(precision)f", value.wrappedValue))
                }
            case .textEditor(value: let value, placeholder: _):
                TextEditor(
                    text: value
                )
                .frame(minHeight: 40, maxHeight: 100)
                .font(.system(size: 16))
            }
        }
    }
    
    
}
//
//struct ChatRoomConfigView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatRoomConfigView(isKeyPresented: .constant(true), chatModel:  AIChatModel(roomID: nil)).environmentObject(EnvironmentChatRoom(chatRoom: ChatRoomStore.shared.chatRoom(ChatRoomStore.shared.lastRoomId())))
//    }
//}



#Preview {
    ChatSessionSettingView()
        .environmentObject(ChatSessionConfig())
}
