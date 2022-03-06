//
//  WeatherResponse.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit
import Foundation

struct ForecastResult: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastList]
}

struct ForecastList: Codable {
    let main: ForecastMain
    let weather: [ForecastWeather]
    let dt_txt: String
}

struct ForecastMain: Codable {
    let temp: Double
}

struct ForecastWeather: Codable {
    let description: String
    let icon: String
}

extension ForecastList {
    
    func getDayIndex() -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.date(from: self.dt_txt)!
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.weekday, from: time) - 1
    }
    
    func getTime() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let time = dateFormatter.date(from: self.dt_txt)!
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: time)
    }
}

extension ForecastMain {

    func getTemperature() -> String {
        return String(round(self.temp-273.15)) + "˚C"
    }
}

extension ForecastWeather {
    
    func getImage() -> UIImage {
        if let data = try? Data(contentsOf:URL(string: "https://openweathermap.org/img/wn/" + self.icon + "@2x.png")!) {
        if let image = UIImage(data: data) {
            return image
            }}
        return UIImage(named: "cloud")!
    }
    
}

struct CurrentResult: Codable {
    let weather: [CurrentWeather]
    let main: CurrentMain
    let wind: CurrentWind
    let clouds: CurrentClouds
    let sys: CurrentSys
    let name: String
}

struct CurrentMain: Codable {
    let temp: Double
    let pressure: Double
    let humidity: Double
}

struct CurrentWeather: Codable {
    let main: String
    let icon: String
}

struct CurrentWind: Codable {
    let speed: Double
    let deg: Double
}

struct CurrentClouds: Codable {
    let all: Double
}

struct CurrentSys: Codable {
    let country: String
}

enum Direction: String {
    case n, nne, ne, ene, e, ese, se, sse, s, ssw, sw, wsw, w, wnw, nw, nnw
}

extension Direction: CustomStringConvertible  {
    static let all: [Direction] = [.n, .nne, .ne, .ene, .e, .ese, .se, .sse, .s, .ssw, .sw, .wsw, .w, .wnw, .nw, .nnw]
    init(_ direction: Double) {
        let index = Int((direction + 11.25).truncatingRemainder(dividingBy: 360) / 22.5)
        self = Direction.all[index]
    }
    var description: String {
        return rawValue.uppercased()
    }
}
