//
//  SideMenuViewController.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/22.
//

import UIKit
import SwiftUI

class SideMenuViewController: UIViewController {
    
    lazy var menuListView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.dataSource = self
        v.delegate = self
        v.separatorStyle = .none
        v.backgroundColor = .clear
        v.register(MenuListCell.self, forCellReuseIdentifier: "MenuListCell")
        return v
    }()
    
    let globleSettingButton = UIButton().then { b in
        b.setBackgroundImage(UIImage(systemName: "gear.circle"), for: .normal)
        b.addTarget(self, action: #selector(presentGlobleSetting), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        view.addSubview(menuListView)
        view.addSubview(globleSettingButton)
        menuListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(44)
        }
        globleSettingButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.left.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.width.height.equalTo(24)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        menuListView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !GlobleStateManager.shared.isSideMenuShow {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        GlobleStateManager.shared.isSideMenuShow = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if GlobleStateManager.shared.isSideMenuShow {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        GlobleStateManager.shared.isSideMenuShow = false
    }
    
    @objc func presentGlobleSetting() {
        let hostingVC = UIHostingController(
            rootView: ChatGlobleSettingView()
                .environmentObject(ChatGlobleConfigManager.shared.config)
        )
        present(hostingVC, animated: true)
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatSessionsManager.chatSessionConfigs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuListCell", for: indexPath)
        
        if let cell = cell as? MenuListCell {
            cell.contentLabel.text = ChatSessionsManager.chatSessionConfigs[indexPath.row].sessionName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = ChatSessionsManager.shared.currentSessionViewMode else {
            return
        }
        viewModel.config = ChatSessionsManager.chatSessionConfigs[indexPath.row]
        viewModel.delegate?.scrollToBottom(animated: false)
        dismiss(animated: true)
    }
}

extension SideMenuViewController: UIContextMenuInteractionDelegate {
    
    // MARK: - Action Handlers
    private func handleDeleteAction(at indexPath: IndexPath) {
        // 实现删除消息的逻辑
        ChatSessionsManager.chatSessionConfigs.remove(at: indexPath.row)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let cell = interaction.view as? ChatListCell,
              let indexPath = menuListView.indexPath(for: cell) else {
            return nil
        }
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // 创建删除消息的action
            let delete = UIAction(title: "删除会话", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // 处理删除消息逻辑
                self.handleDeleteAction(at: indexPath)
            }
            
            // 返回所有actions
            return UIMenu(title: "", children: [delete])
        }
        return config
    }
    
}

