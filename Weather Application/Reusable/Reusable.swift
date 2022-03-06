//
//  Reusable.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit

class Reusable: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelValue: UILabel!
    
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

extension NSObject {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
