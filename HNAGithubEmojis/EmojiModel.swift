//
//  EmojiModel.swift
//  HNAGithubEmojis
//
//  Created by __无邪_ on 2017/9/5.
//  Copyright © 2017年 __无邪_. All rights reserved.
//

import UIKit

class EmojiModel {

    var name: String?   // 名称
    var value: String?  // 图片地址
    var height: CGFloat
    var width: CGFloat
    
    init(_ info:Dictionary<String, Any>) {
        self.name = info["name"] as? String
        self.value = info["value"] as? String
        self.height = info["height"] as! CGFloat
        self.width = info["width"] as! CGFloat
    }
    
}
