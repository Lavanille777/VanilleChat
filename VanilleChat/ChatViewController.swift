//
//  ChatViewController.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/19.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
import SideMenu
import SwiftUI

class ChatViewController: UIViewController, ChatSessionViewModelDelegate {
    @objc func scrollToBottom(animated: Bool = true) {
        guard viewModel.dataSource.count > 0 else { return }
        print("scrollToBottomWithAnimation\(animated)")
        chatListView.scrollToRow(
            at: IndexPath(row: viewModel.dataSource.count - 1, section: 0),
            at: .bottom,
            animated: animated
        )
    }
    
    @objc func scrollToBottomWithAnimation() {
        scrollToBottom(animated: true)
    }
    
    func reloadList() {
        chatListView.reloadData()
        self.title = viewModel.config.sessionName
    }
    
    func reloadLastItem() {
        chatListView.reloadRows(at: [IndexPath(row: viewModel.dataSource.count - 1, section: 0)], with: .automatic)
    }
    
    lazy var chatListView: ChatListView = {
        let v = ChatListView(frame: .zero, style: .plain)
        v.backgroundColor = .systemBackground
        v.dataSource = self
        v.delegate = self
        v.separatorStyle = .none
        v.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell")
        v.register(ChatListCell.self, forCellReuseIdentifier: "ChatListImageCell")
        v.register(ChatListCell.self, forCellReuseIdentifier: "ChatListMarkDownCell")
        // 检查是否在 Mac Catalyst 环境下运行
        #if targetEnvironment(macCatalyst)
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        v.contentInsetAdjustmentBehavior = .always
        #endif
        return v
    }()
    
    lazy var chatInputView = ChatInputView().then { v in
        v.addonsBLK = { [weak self] in
            guard let self else { return }
            viewModel.sendMessage(content: v.inputTextView.text)
            v.inputTextView.text = ""
        }
    }
    
    lazy var downButton = UIVisualEffectView(
        effect: UIBlurEffect(
            style: .systemThinMaterial
        )
    ).then { v in
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 14
        v.isHidden = true
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.down.to.line"), for: .normal)
        button.addTarget(self, action: #selector(scrollToBottomWithAnimation), for: .touchUpInside)
        button.tintColor = .darkGray
        v.contentView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    var contentView = UIView()
    
    var viewModel = ChatSessionViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        ChatSessionsManager.shared.currentSessionViewMode = viewModel
        viewModel.delegate = self
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward"),
                style: .plain,
                target: self,
                action: #selector(presentMenuPage)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "plus.square.on.square"),
                style: .plain,
                target: self,
                action: #selector(createNewPage)
            )
        ]
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "gear"),
                style: .plain,
                target: self,
                action: #selector(settingPage)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "eraser.fill"),
                style: .plain,
                target: self,
                action: #selector(clearMessages)
            )
        ]
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = viewModel.config.sessionName
        scrollToBottom(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatListView.contentInset.bottom = GlobleStateManager.shared.mainWindow.safeAreaInsets.bottom + chatInputView.frame.height
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardFrameWillShow(noti:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardFrameWillHide(noti:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardFrameWillChange(noti:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(safaAreaDidChange(noti:)),
            name: .init(ViewSafeAreaInsetsDidChangeNotification),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowSizeDidChange(noti:)),
            name: .init(WindowSizeWillChangNotification),
            object: nil
        )
    }
    
    @objc func keyboardFrameWillChange(noti: Notification) {
        guard let keyboardFrame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        GlobleStateManager.shared.keyboardFrame = keyboardFrame
    }
    
    @objc func keyboardFrameWillShow(noti: Notification) {
        guard let keyboardFrame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        GlobleStateManager.shared.keyboardFrame = keyboardFrame
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom(animated: true)
        }

        UIView.animate(withDuration: 0.25) {
            self.contentView.snp.remakeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.bottom.equalToSuperview().inset(keyboardFrame.height - GlobleStateManager.shared.mainWindow.safeAreaInsets.bottom)
            }
            self.view.layoutIfNeeded()
        } completion: { isFinished in
            self.viewModel.isShowingKeyboard = true
        }
    }
    
    @objc func keyboardFrameWillHide(noti: Notification) {
        GlobleStateManager.shared.keyboardFrame = .zero
        viewModel.isShowingKeyboard = false
        UIView.animate(withDuration: 0.25) {
            self.contentView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func windowSizeDidChange(noti: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reloadList()
        }
    }
    
    @objc func safaAreaDidChange(noti: Notification) {
//        chatListView.contentInset.bottom = GlobleStateManager.shared.mainWindow.safeAreaInsets.bottom + chatInputView.frame.height
    }
    
    func setupUI() {
        view.addSubview(contentView)
        contentView.addSubview(chatListView)
        contentView.addSubview(chatInputView)
        contentView.addSubview(downButton
        )
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        chatListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(contentView.safeAreaInsets)
        }
        
        chatInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        downButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(chatInputView.snp.top).offset(-5)
            make.width.height.equalTo(28)
        }
    }
    
    @objc func presentMenuPage() {
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true)
    }
    
    @objc func createNewPage() {
        let sessionConfig = ChatSessionConfig()
        ChatSessionsManager.chatSessionConfigs.append(ChatSessionConfig())
        ChatSessionsManager.shared.currentSessionConfig = sessionConfig
        viewModel.config = sessionConfig
        title = viewModel.config.sessionName
    }
    
    @objc func settingPage() {
        let vc = UIHostingController(
            rootView: ChatSessionSettingView()
                .environmentObject(viewModel.config)
        )
        vc.title = "聊天设置"
        vc.navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.pushViewController(
            vc,
            animated: true
        )
    }
    
    @objc func clearMessages() {
        let alert = UIAlertController(title: "删除当前会话所有消息", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            viewModel.dataSource.removeAll()
            viewModel.config.compressedMemoryList.removeAll()
            viewModel.saveMessagesToFile()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

}

class ChatListView: UITableView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = ChatListCellModel(from: viewModel.dataSource[indexPath.row])
        var cellID = "ChatListCell"
        if ChatListCell.containsMarkdown(model.text) {
            cellID = "ChatListMarkDownCell"
            if !ChatListCell.extractImageURLs(from: model.text).isEmpty {
                cellID = "ChatListImageCell"
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        if let cell = cell as? ChatListCell {
            cell.parent = self
            
            if indexPath.row == viewModel.dataSource.count - 1 {
                model.updateWithAnim = true
            }
            cell.model = model
            if cell.interactions.isEmpty {
                let interaction = UIContextMenuInteraction(delegate: self)
                cell.addInteraction(interaction)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // 或者任何合适的预估值
    }
    
    // MARK: - Action Handlers

    private func handleResendAction(at indexPath: IndexPath) {
        // 实现重新发送消息的逻辑
    }

    private func handleCopyAction(at indexPath: IndexPath) {
        // 实现复制消息内容的逻辑
        let message = viewModel.dataSource[indexPath.row].content
        UIPasteboard.general.string = message
    }

    private func handleDeleteAction(at indexPath: IndexPath) {
        // 实现删除消息的逻辑
        let removedMessage = viewModel.dataSource.remove(at: indexPath.row)
        for (index, message) in viewModel.config.compressedMemoryList.enumerated() {
            if message.created == removedMessage.created {
                viewModel.config.compressedMemoryList.remove(at: index)
                break
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        
        guard let navBar = navigationController?.navigationBar else { return }
        let safeAreaBottom = GlobleStateManager.shared.mainWindow.safeAreaInsets.bottom
        let scrollViewHeight = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        let inputViewHeight = viewModel.isShowingKeyboard ? chatInputView.frame.size.height - safeAreaBottom : chatInputView.frame.size.height
        
        var gap = contentHeight - (scrollViewHeight + scrollView.contentOffset.y - navBar.frame.maxY - inputViewHeight)
        
        guard contentHeight > 0 else { return }
        
#if targetEnvironment(macCatalyst)
        gap -= 20
#endif
        
        if gap < 70 + (viewModel.isShowingKeyboard ? 0 : safeAreaBottom) {
            print("scroll at bottom gap:\(gap)")
            viewModel.isAtBottom = true
        } else if gap > 40 {
            print("scroll leave bottom gap:\(gap)")
            viewModel.isAtBottom = false
        }
        
        downButton.isHidden = viewModel.isAtBottom
        
    }
}

extension ChatViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let cell = interaction.view as? ChatListCell,
              let indexPath = chatListView.indexPath(for: cell) else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // 创建重新发送的action
            let resend = UIAction(title: "重新发送", image: UIImage(systemName: "paperplane")) { action in
                // 处理重新发送逻辑
                self.handleResendAction(at: indexPath)
            }
            
            // 创建复制内容的action
            let copy = UIAction(title: "复制内容", image: UIImage(systemName: "doc.on.doc")) { action in
                // 处理复制内容逻辑
                self.handleCopyAction(at: indexPath)
            }
            
            // 创建删除消息的action
            let delete = UIAction(title: "删除消息", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // 处理删除消息逻辑
                self.handleDeleteAction(at: indexPath)
            }
            
            let menu = UIMenu(title: "", children: [resend, copy, delete])
            
            // 返回所有actions
            return UIMenu(title: "", children: [resend, copy, delete])
        }
        return config
    }
    
}
