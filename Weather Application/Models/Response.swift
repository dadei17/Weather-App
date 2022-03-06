//
//  ForecastResponse.swift
//  Weather Application
//
//  Created by GEOLAB TRAININGS on 2/15/20.
//  Copyright © 2020 Free University. All rights reserved.
//

import Foundation

struct ForecastResult: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [Forecast]
}

struct Forecast: Codable {
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

