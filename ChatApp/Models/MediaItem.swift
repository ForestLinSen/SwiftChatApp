//
//  MediaItem.swift
//  ChatApp
//
//  Created by Sen Lin on 16/1/2022.
//

import Foundation
import UIKit
import MessageKit

struct PhotoMessage: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
