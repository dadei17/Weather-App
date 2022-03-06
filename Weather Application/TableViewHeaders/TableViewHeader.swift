//
//  TableViewHeader.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit

class TableViewHeader: UITableViewHeaderFooterView {
    
    
    @IBOutlet weak var label: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func configure(_ day:String){
        self.tintColor = .clear
        self.backgroundView?.backgroundColor = .clear
        label.text = day
    }

}
