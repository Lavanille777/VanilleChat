//
//  ChatListCell.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/20.
//

import UIKit
import SwiftUI
import MarkdownUI
import SwiftyMarkdown
import SDWebImage
import NetworkImage
import SDWebImageSwiftUI
import SnapKit
import JXPhotoBrowser

enum ChatListCellType {
    case user
    case assistant
}

// MARK: - WebImageProvider

struct WebImageProvider: ImageProvider {
  func makeImage(url: URL?) -> some View {
      EmptyView()
  }
}

struct WebImageInlineProvider: InlineImageProvider {
    
    var didFetchImageURL: ((URL)->())?
    
    func image(with url: URL, label: String) async throws -> Image {
        return Image("")
    }
}

extension InlineImageProvider where Self == WebImageInlineProvider {
  static var webInlineImage: Self {
    .init()
  }
}

extension ImageProvider where Self == WebImageProvider {
    static var webImage: Self {
        .init()
    }
}

// MARK: - ResizeToFit

/// A layout that resizes its content to fit the container **only** if the content width is greater than the container width.
struct ResizeToFit: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let view = subviews.first else {
            return .zero
        }
        
        var size = view.sizeThatFits(.unspecified)
        
        if let width = proposal.width, size.width > width {
            let aspectRatio = size.width / size.height
            size.width = width
            size.height = width / aspectRatio
        }
        return size
    }
    
    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        guard let view = subviews.first else { return }
        view.place(at: bounds.origin, proposal: .init(bounds.size))
    }
}

extension Theme {
  static let fancy = Theme()
    .code {
      FontFamilyVariant(.monospaced)
      FontSize(.em(0.85))
    }
    .link {
        ForegroundColor(.blue)
    }
    .paragraph { configuration in
      configuration.label
        .relativeLineSpacing(.em(0.25))
        .markdownMargin(top: 0, bottom: 0)
    }
}

struct MarkdownLabel: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var sizeDidChange: ((CGSize)->())?
    var content: String = ""
    var role: Chat.Role = .user
    var body: some View {
        Markdown(content)
            .markdownImageProvider(.webImage)
            .markdownInlineImageProvider(.webInlineImage)
            .markdownBlockStyle(\.image) { configuration in
                configuration.label
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 8, y: 8)
                    .markdownMargin(top: .em(1.6), bottom: .em(1.6))
            }
            .markdownTextStyle(textStyle: {
                ForegroundColor( role == .user ? .primary.opacity(0.8) : Color("assistantTextColor"))
                FontSize(16)
            })
            .markdownTextStyle(\.link, textStyle: {
                ForegroundColor(.blue)
                FontSize(16)
            })
            .markdownBlockStyle(\.table) { configuration in
                configuration.label
                    .markdownTableBackgroundStyle(
                        .alternatingRows(Color.cyan.opacity(0.8), .clear, header: .clear)
                    )
                    .markdownTableBorderStyle(
                        .init(color: role == .user ? .primary.opacity(0.8) : .white)
                    )
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .background(
                Color(role == .user ? "TextBackgroundUser" : "TextBackgroundAssistant")
            )
            .padding(0)
            .selectionDisabled(false)
            .textSelection(.enabled)
            .background(GeometryReader { geometryProxy in
                Color.clear
                    .onChange(of: geometryProxy.size, { oldValue, newValue in
                        if let sizeDidChange {
                            sizeDidChange(newValue)
                        }
                    })
            })
    }
        
}

class ChatListCellModel {
    var avatarURL: String = ""
    var type: Chat.Role = .user
    var text: String = ""
    var textColor: UIColor = .label
    var textFont: UIFont = .systemFont(ofSize: 17, weight: .regular)
    var bubbleUserColor: UIColor = .textBackgroundUser 
    var bubbleAssistantColor: UIColor = .textBackgroundAssistant
    var updateWithAnim: Bool = false
    var cellSizeDidChange: ((CGSize)->())?
    var originalSize: CGSize = .zero
    var image: UIImage?
    
    init(
        avatarURL: String = "",
        type: Chat.Role = .user,
        text: String = "",
        textColor: UIColor = .label,
        textFont: UIFont = .systemFont(ofSize: 17, weight: .regular),
        bubbleUserColor: UIColor = UIColor(named: "TextBackgroundUser") ?? .clear,
        bubbleAssistantColor: UIColor = UIColor(named: "TextBackgroundAssistant") ?? .clear
    ) {
        self.avatarURL = avatarURL
        self.type = type
        self.text = text
        self.textColor = textColor
        self.textFont = textFont
        self.bubbleUserColor = bubbleUserColor
        self.bubbleAssistantColor = bubbleAssistantColor
    }
    
    init(
        from chatMessage: ChatMessage
    ) {
        type = chatMessage.role
        text = chatMessage.content
    }
}

class ChatListCell: UITableViewCell {
    
    var model = ChatListCellModel() {
        didSet {
            loadModel()
        }
    }
    
    var type: ChatListCellType = .user
    
    var firstLoad: Bool = true
    
    var parent: UIViewController!
    
    var useMarkDown: Bool = false
    
    var delayLoad: Bool = false
    
    var avatarImageView = UIImageView(
        image: UIImage(
            named: "chatgpt-icon-user"
        )
    ).then { v in
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
    }
    var imageHeightConstraint: Constraint?
    
    var nameLabel = UILabel().then { l in
        l.textColor = .sideMenuText
        l.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    var bubbleView = UIView().then { v in
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        v.layer.cornerCurve = .continuous
    }
    
    var imgViews: [UIImageView] = []
    
    var imgRatio: CGFloat = 1
    
    var markDownLabel: UIView {
        markDownBridgeVC.view
    }
    
    var markDownBridgeVC = UIHostingController(rootView: MarkdownLabel())
    
    var textMessageLabel = UITextView().then { l in
//        l.numberOfLines = 0
        l.backgroundColor = .clear
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? UIView,
           object === markDownBridgeVC.view,
           (keyPath == "frame" || keyPath == "bounds"),
           model.updateWithAnim
        {
            if let oldValue = change?[NSKeyValueChangeKey.oldKey] as? CGRect,
               let newValue = change?[NSKeyValueChangeKey.newKey] as? CGRect,
               oldValue != newValue
            {
                guard let superview = superview as? UITableView else { return }
//                UIView.performWithoutAnimation {
//                    superview.beginUpdates()
//                    superview.endUpdates()
//                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print("cell didMoveToSuperview")
        if delayLoad {
            setupLayout()
        }
    }
    
    func setupLayout() {
        guard let superview else {
            delayLoad = true
            return
        }
        
        contentView.subviews.forEach { v in
            v.removeFromSuperview()
        }
        bubbleView.subviews.forEach { v in
            v.removeFromSuperview()
        }
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bubbleView)

        avatarImageView.snp.remakeConstraints { make in
            if model.type == .assistant {
                make.leading.equalToSuperview().inset(10)
            } else {
                make.trailing.equalToSuperview().inset(10)
            }
            make.top.equalToSuperview().inset(5)
            make.width.height.equalTo(24)
        }
        
        nameLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            if model.type == .assistant {
                make.left.equalTo(avatarImageView.snp.right).offset(5)
            } else {
                make.right.equalTo(avatarImageView.snp.left).offset(-5)
            }
        }
        
        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            if model.type == .assistant {
                make.leading.equalToSuperview().inset(10)
                make.trailing.lessThanOrEqualToSuperview().inset(15)
            } else {
                make.trailing.equalToSuperview().inset(10)
                make.leading.greaterThanOrEqualToSuperview().inset(20)
            }
            make.bottom.equalToSuperview().inset(5)
        }
        
        if useMarkDown {
            bubbleView.addSubview(markDownLabel)
            markDownLabel.snp.remakeConstraints { make in
                if imgViews.isEmpty {
                    make.edges.equalToSuperview().inset(12)
                } else {
                    make.top.left.right.equalToSuperview().inset(12)
                    if let subview = markDownLabel.subviews.first {
                        make.height.equalTo(subview.frame.height)
                    }
                }
            }
            bubbleView.layoutIfNeeded()
            
            markDownLabel.subviews.forEach { subview in
                print("markDownLabel  \(subview.frame)")
            }
            
            for (index, imgV) in imgViews.enumerated() {
                bubbleView.addSubview(imgV)
                imgV.snp.remakeConstraints { make in
                    if index == 0 {
                        make.top.equalTo(markDownLabel.snp.bottom).offset(5)
                    } else {
                        make.top.equalTo(imgViews[index - 1].snp.bottom).offset(5)
                    }
                    make.left.right.equalTo(markDownLabel)
                    let width = superview.frame.width - 49
                    make.height.equalTo(
                        width * imgRatio
                    )
                    make.bottom.equalToSuperview().inset(12)
                }
            }
        } else {
            bubbleView.addSubview(textMessageLabel)
            textMessageLabel.snp.remakeConstraints { make in
                make.left.right.equalToSuperview().inset(8)
                make.top.bottom.equalToSuperview().inset(5)
            }
        }
    }
    
    func setupUI() {
        
    }
    
    func loadModel() {
        
        delayLoad = false
        
        imgViews.removeAll()
        
        if !model.avatarURL.isEmpty {
            avatarImageView.image = UIImage(contentsOfFile: model.avatarURL)
        }
        
        let text = model.text
        
        useMarkDown = ChatListCell.containsMarkdown(text)
        
        if useMarkDown {
            let urls = ChatListCell.extractImageURLs(from: text)
            imgRatio = extractAspectRatio(from: text)
            urls.forEach { url in
                let imageView = UIImageView()
                imageView.isUserInteractionEnabled = true
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewImage)))
                imageView.sd_setImage(with: url) { [weak self] image, _, cacheType, _ in
                    self?.model.image = image
//                    guard let self, let superview = superview as? UITableView else { return }
//                    self.imgViews.append(imageView)
//                    print("=======cacheType :\(cacheType)")
//                    if cacheType != .memory {
//                        
//                    }
                }
                self.imgViews.append(imageView)
            }
            markDownBridgeVC.rootView = MarkdownLabel(
                sizeDidChange: { size in
                    DispatchQueue.main.async {
                        self.setupLayout()
                    }
                    print("markdownlabel size changed: \(size)")
                },
                content: text,
                role: model.type
            )
            markDownBridgeVC.loadView()
            markDownBridgeVC.view.layoutIfNeeded()
        } else {
            textMessageLabel.then { l in
                l.isScrollEnabled = false
                l.isEditable = false
                l.isSelectable = true
                l.contentMode = .center
                // 创建 NSMutableParagraphStyle 实例来设置行间距属性
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4

                // 创建属性化字符串，将段落样式应用于文本
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(.foregroundColor, value: UIColor.assistantText, range: NSMakeRange(0, attributedString.length))
                attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, attributedString.length))
                
                // 将属性化字符串设置给 UILabel
                let md = SwiftyMarkdown(string: text).attributedString()
                l.attributedText = md
                l.sizeToFit()
                
                
            }
        }
        
        nameLabel.text = model.type == .user ? "YOU" : "GPT"
        bubbleView.backgroundColor = model.type == .user ? model.bubbleUserColor : model.bubbleAssistantColor
        self.setupLayout()
    }
    
    func extractAspectRatio(from string: String) -> CGFloat {
        // 使用正则表达式匹配宽度和高度
        let pattern = "\"size\":\"(\\d+)x(\\d+)\""
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = string as NSString

        let results = regex?.matches(in: string, range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first {
            // 提取宽度和高度的值
            let widthRange = match.range(at: 1)
            let heightRange = match.range(at: 2)
            
            if let widthString = nsString.substring(with: widthRange) as String?,
               let heightString = nsString.substring(with: heightRange) as String?,
               let width = Double(widthString),
               let height = Double(heightString) {
                // 返回宽高比
                return CGFloat(height / width)
            }
        }
        
        // 如果没有匹配到或者有任何错误，返回 1
        return 1
    }
    
    @objc func viewImage() {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            1
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.presentImageMenu(_:))))
            browserCell?.imageView.image = self.model.image
        }
        
        browser.show()
    }
    
    @objc func presentImageMenu(_ gesture: UILongPressGestureRecognizer) {
        guard let cell = gesture.view as? JXPhotoBrowserImageCell else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.overrideUserInterfaceStyle = .dark
        let action1 = UIAlertAction(title: "保存到相册", style: .default) { (alert) in
            if let image = cell.imageView.image {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaved(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        let action2 = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(action1)
        alert.addAction(action2)
        cell.photoBrowser?.present(alert, animated: true)
    }
    
    @objc func imageSaved(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let e = error {
            UIView.makeToast(e.localizedDescription)
        } else {
            UIView.makeToast("保存成功")
        }
    }
    
    class func extractImageURLs(from markdownText: String) -> [URL] {
        let pattern = "!\\[[^\\]]*\\]\\((.*?)\\)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = markdownText as NSString
        let results = regex?.matches(in: markdownText, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var urls: [URL] = []
        
        results?.forEach {
            let matchRange = $0.range(at: 1)
            let url = nsString.substring(with: matchRange)
            if let imageUrl = URL(string: url) {
                urls.append(imageUrl)
            }
        }
        return urls
    }
    
    class func containsMarkdown(_ text: String) -> Bool {
        let patterns = [
            "^(#{1,6}\\s)",                     // 标题
            "\\!\\[.*?\\]\\(.*?\\)|\\[.*?\\]\\(.*?\\)", // 图片和链接
            "\\*\\*.*?\\*\\*|__.*?__|_.*?_|\\*.*?\\*",   // 粗体和斜体
            "```.*?```|`.*?`",                  // 代码块
            "^(\\*|-|\\+|\\d+\\.)\\s",          // 列表
            """
            \\|(?:([^\\r\\n|]*)\\|)+\\r?\\n\\|(?:(:?-+:?)\\|)+\\r?\\n(\\|(?:([^\\r\\n|]*)\\|)+\\r?\\n)+
            """,
            "^>\\s",                            // 引用
            "^-{3,}$|^\\*{3,}$|^_{3,}$"         // 水平线
        ]
        let tablePattern = """
            \\|.*?\\|\\s*\\n\\|\\s*:?-+:?\\s*(\\|\\s*:?-+:?\\s*)+\\n(\\|.*?\\|\\s*\\n)+
            """

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) {
                let range = NSRange(text.startIndex..<text.endIndex, in: text)
                if regex.firstMatch(in: text, options: [], range: range) != nil {
                    return true
                }
            }
        }

        return false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model.image = nil
        delayLoad = false
        self.imgViews.removeAll()
        contentView.subviews.forEach { v in
            v.removeFromSuperview()
        }
        bubbleView.subviews.forEach { v in
            v.removeFromSuperview()
        }
    }

}

#Preview {
    ChatListCell()
}
