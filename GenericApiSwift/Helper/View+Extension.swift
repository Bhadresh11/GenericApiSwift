//
//  View+Extension.swift
//  GenericApiSwift
//
//  Created by Apple on 04/06/23.
//

import UIKit

extension UIView {
    
    func applyBorder() {
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.borderWidth = 1.0
    }
    
}
