//
//  ChatGlobleSettingView.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/24.
//

import SwiftUI

struct ChatGlobleSettingView: View {
    @EnvironmentObject var config: ChatGlobleConfig
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if config.apiKeys.count > 0 {
                        ForEach(config.apiKeys.indices, id: \.self) { index in
                            HStack() {
                                TextField("请输入 API Key", text: $config.apiKeys[index])
                            }.swipeActions {
                                Button {
                                    config.apiKeys.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                    
                    
                    Button {
                        config.apiKeys.append("")
                    } label: {
                        HStack {
                            Spacer()
                            Text("添加一条")
                                .foregroundStyle(Color.blue)
                            Spacer()
                        }
                    }
                } header: {
                    Text("设置可用的 API Key")
                } footer: {
                    Text("可在会话设置中选择")
                }
                
                Section {
                    if config.apiHosts.count > 0 {
                        ForEach(config.apiHosts.indices, id: \.self) { index in
                            HStack() {
                                TextField("请输入 API Host", text: $config.apiHosts[index])
                            }.swipeActions {
                                Button {
                                    config.apiHosts.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                    
                    
                    Button {
                        config.apiHosts.append("")
                    } label: {
                        HStack {
                            Spacer()
                            Text("添加一条")
                                .foregroundStyle(Color.blue)
                            Spacer()
                        }
                    }
                } header: {
                    Text("设置可用的 API Host")
                } footer: {
                    Text("可在会话设置中选择")
                }
            }
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
        }
        
    }
}

#Preview {
    ChatGlobleSettingView()
        .environmentObject(ChatGlobleConfig())
}
