//
//  CollectionViewCell.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/5/21.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var currentImageView: UIImageView!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    
    @IBOutlet weak var cloudness: ReusableView!
    @IBOutlet weak var humidity: ReusableView!
    
    @IBOutlet weak var speed: ReusableView!
    @IBOutlet weak var direction: ReusableView!
    
    
    
    @IBOutlet weak var baseLine: UIView!
    @IBOutlet weak var rotateLine: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 20
    }
    
    func configureReusableViewImages(_ cloudness: String = "Cloudness",_ humidity: String = "Humidity",_ speed: String = "Wind Speed",_ direction: String = "Wind Direction") {
        DispatchQueue.main.async {
            self.cloudness.icon.image = UIImage(named: cloudness)
            self.humidity.icon.image = UIImage(named: humidity)
            self.speed.icon.image = UIImage(named: speed)
            self.direction.icon.image = UIImage(named: direction)
            
            self.cloudness.labelName.text = cloudness
            self.humidity.labelName.text = humidity
            self.speed.labelName.text = speed
            self.direction.labelName.text = direction
            
            self.cloudness.icon.tintColor = .yellow
            self.humidity.icon.tintColor = .yellow
            self.speed.icon.tintColor = .yellow
            self.direction.icon.tintColor = .yellow
        }
    }
    
    func configure(_ model: CollectionCellModel) {
        configureReusableViewImages()
        self.baseLine.isHidden = !model.middlePosition
        self.rotateLine.isHidden = model.middlePosition
        self.currentImageView.image = UIImage(data: model.image)
        self.currentLocation.text = model.location
        self.currentWeather.text = model.weather
        self.cloudness.labelValue.text = model.cloudness
        self.humidity.labelValue.text = model.humidity
        
        self.speed.labelValue.text = model.speed
        self.direction.labelValue.text = model.degree
        
    }

}
