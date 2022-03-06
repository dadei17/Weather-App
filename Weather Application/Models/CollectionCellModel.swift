//
//  CollectionCellModel.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/6/21.
//

import UIKit

struct CollectionCellModel: Codable {
    var middlePosition: Bool
    var cloudness: String = "1 %"
    var humidity: String = "100 mm"
    var speed: String = "0.1 km/h"
    var degree: String = "N"
    var image: Data
    var location: String
    var weather: String
}
