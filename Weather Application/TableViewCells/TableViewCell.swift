//
//  TableViewCell.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var temp: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(_ model: RowModel) {
        self.icon.image = model.icon
        self.time.text = model.time
        self.weather.text = model.weather
        self.temp.text = model.temp
    }

}
