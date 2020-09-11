//
//  CardView.swift
//  TinderSwipe
//
//  Created by MB on 11/09/2020.
//  Copyright © 2020 MB. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = CGFloat(12)
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = CGFloat(6)
    }
    
}
