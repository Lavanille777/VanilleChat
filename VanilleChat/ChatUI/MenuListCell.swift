//
//  MenuListCell.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/22.
//

import UIKit

class MenuListCell: UITableViewCell {
    
    var cardView = UIView().then { v in
        v.backgroundColor = .darkGray.withAlphaComponent(0.5)
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        v.layer.cornerCurve = .continuous
    }
    
    var contentLabel = UILabel().then { l in
        l.textColor = .sideMenuText
        l.font = .systemFont(ofSize: 17)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    func setupUI() {
        contentView.addSubview(cardView)
        cardView.addSubview(contentLabel)
        
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
