//
//  CircleImage.swift
//  Wind Searched
//
//  Created by Hamza Shahbaz on 7/01/20.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

@IBDesignable
class CircleImage: UIImageView {

    override func awakeFromNib() {
        setUpView()
    }
    func setUpView(){
        self.layer.cornerRadius = self.frame.width/2
        self.clipsToBounds = true
        
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }

}
