//
//  AddButtonReuse.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/7/21.
//

import UIKit

class AddButtonReuse: UIView {
    
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        let bundle = Bundle.main
        bundle.loadNibNamed(className, owner: self, options: nil)
        
        guard let content = contentView else {
            fatalError("contentView Not Set")
        }
        
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(content)
    }
}
