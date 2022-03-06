//
//  AddButton.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/7/21.
//

import UIKit

class AddButton: AddButtonReuse{
    
    @IBOutlet weak var button: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.button.layer.cornerRadius = self.frame.width / 2
        self.button.backgroundColor = .white
        
        self.button.titleLabel?.textColor = .clear
        self.button.titleLabel?.text = "+"
        self.button.titleLabel?.font = .systemFont(ofSize: 60)
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        
    }
}
