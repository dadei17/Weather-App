//
//  ErrorViewController.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit

class ErrorViewController: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var reloadBut: UIButton!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var errorIcon: UIImageView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
        reloadBut.layer.borderWidth = 1
        reloadBut.layer.cornerRadius = 10
        reloadBut.layer.borderColor = UIColor.yellow.cgColor
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(content)
    }
    
    var delegate: ErrorViewControllerDelegate?
    
    @IBAction func handleReload(_ sender: Any) {
        self.delegate?.handleReload()
    }
}

protocol ErrorViewControllerDelegate {
    func handleReload()
}
