//
//  MaterialImage.swift
//  Socialite
//
//  Created by user on 27/09/2016.
//  Copyright © 2016 David Kennedy. All rights reserved.
//

import UIKit

class MaterialImage: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = 10.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }

}
