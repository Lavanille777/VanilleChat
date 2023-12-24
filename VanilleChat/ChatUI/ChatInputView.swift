//
//  ChatInputView.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/19.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift

class ChatInputView: UIView {
    
    @objc var addonsBLK: (()->())?
    
    private var effectView = UIVisualEffectView(
        effect: UIBlurEffect(
            style: .systemUltraThinMaterial
        )
    )
    
    private lazy var addonsButton = UIButton().then { v in
        v.setImage(
            UIImage(
                systemName: "photo.badge.plus"
            ),
            for: .normal
        )
        v.addTarget(
            self,
            action: #selector(addonsAction),
            for: .touchUpInside
        )
    }
    
    lazy var inputTextView = InputTextView().then { v in
        v.placeholder = "想说点什么"
        v.placeholderTextColor = .secondaryLabel
        v.backgroundColor = .secondarySystemBackground
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray4.cgColor
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        v.layer.cornerCurve = .continuous
        v.delegate = self
        v.keyCMDDelegate = self
        v.contentInset = UIEdgeInsets(
            top: 4,
            left: 6,
            bottom: 0,
            right: 6
        )
        v.font = .systemFont(ofSize: 16)
    }
    
    private lazy var sendButton = UIButton().then { v in
        v.setImage(
            UIImage(
                systemName: "paperplane.fill"
            )
            , for: .normal
        )
        v.addTarget(
            self,
            action: #selector(addonsAction),
            for: .touchUpInside
        )
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addObservers()
        setupLayout()
        setupUI()
    }
    
    func addObservers() {
        inputTextView.addObserver(
            self,
            forKeyPath: "intrinsicContentSize",
            context: nil
        )
    }
    
    func setupLayout() {
        addSubview(effectView)
        [
            addonsButton,
            inputTextView,
            sendButton
        ].forEach {
            effectView.contentView.addSubview($0)
        }
        
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addonsButton.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).inset(16)
            make.centerY.equalTo(inputTextView)
            make.width.height.equalTo(24)
        }
        
        inputTextView.snp.makeConstraints { make in
            make.leading.equalTo(addonsButton.snp.trailing).offset(10)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10 + GlobleStateManager.shared.mainWindow.safeAreaInsets.bottom)
            make.height.greaterThanOrEqualTo(46)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalTo(safeAreaLayoutGuide).inset(16)
            make.centerY.equalTo(inputTextView)
            make.width.height.equalTo(24)
        }
    }
    
    func setupUI() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func addonsAction() {
        if let addonsBLK {
            addonsBLK()
        }
    }
    
}

class InputTextView: IQTextView {
    var keyCMDDelegate: ChatInputView?
    
    override var keyCommands: [UIKeyCommand] {
        [
            UIKeyCommand(action: #selector(sendMessage), input: "\r")
        ]
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        print("======\(key.charactersIgnoringModifiers)")
        switch key.keyCode {
        case .keyboardReturnOrEnter :
            if let addonsBLK = keyCMDDelegate?.addonsBLK {
                addonsBLK()
            }
        default:
            break
        }
    }
    
    @objc func sendMessage() {
        print("send message")
    }
}

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(textView.contentSize)
        print(textView.frame)
        if textView.frame.height != textView.contentSize.height {
            textView.snp.remakeConstraints { make in
                make.left.equalTo(addonsButton.snp.right).offset(10)
                make.right.equalTo(sendButton.snp.left).offset(-10)
                make.top.equalToSuperview().inset(10)
                make.bottom.equalToSuperview().inset(
                    10 + GlobleStateManager.shared.mainWindow.safeAreaInsets.bottom
                )
                make.height.equalTo(textView.contentSize.height + 10)
            }
        }
    }
}

#Preview {
    ChatInputView()
}
