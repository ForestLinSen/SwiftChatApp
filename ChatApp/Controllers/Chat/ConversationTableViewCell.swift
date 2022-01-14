//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Sen Lin on 31/12/2021.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    private let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(systemName: "person")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        return profileImageView
    }()
    
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Other user"
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        return nameLabel
    }()
    
    private let conversationLabel: UILabel = {
        let conversationLabel = UILabel()
        conversationLabel.text = "latest conversation here"
        conversationLabel.textColor = .gray
        return conversationLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(conversationLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.frame.width / 8
        let padding = imageSize / 5
        profileImageView.frame = CGRect(x: padding,
                                        y: padding,
                                        width: imageSize,
                                        height: imageSize)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        
        nameLabel.frame = CGRect(x: profileImageView.frame.width + padding*2,
                                 y: padding*1.5,
                                 width: imageSize*3,
                                 height: padding*2)
        
        conversationLabel.frame = CGRect(x: profileImageView.frame.width + padding*2,
                                         y: nameLabel.frame.size.height + padding/2,
                                 width: imageSize*3,
                                 height: imageSize)

    }
    
    public func configure(with model: Conversation){
        self.nameLabel.text = model.otherUserName
        self.conversationLabel.text = model.latestMessage.text

        let fileName = "images/\(model.otherUserEmail)_profile_picture.png"
        print("Debug: profile image file name \(fileName)")
  
        StorageManager.shared.getProfileImage(path: fileName) {[weak self] result in
            
            switch result{
            case .failure(let error):
                print("Debug: cannot get profile image url: \(error)")
                
            case .success(let url):
                //imageView.sd_setImage(with: url, completed: nil)
                self?.profileImageView.sd_setImage(with: url, completed: nil)
            }
            
        }
    }
    
}
