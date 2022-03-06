//
//  ForecastController.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit
import CoreLocation


class ForecastController: UIViewController, CLLocationManagerDelegate, ErrorViewControllerDelegate {
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var forecastTableView: UITableView!
    var url = "https://openweathermap.org/forecast5";
    let apiKey = "f1c7f5b840d872080e69d492085a4430"
    let formatter = DateFormatter()
    var data: [SectionModel] = []
    var errorView: ErrorView? = ErrorView()
    
    let gradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [
                UIColor(named: "bg-gradient-start")?.cgColor ?? UIColor.blue.cgColor ,
                UIColor(named: "bg-gradient-end")?.cgColor ?? UIColor.red.cgColor
            ]
            return layer
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        gradientLayer.frame = view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
       
        errorView?.delegate = self
        permission()
        registerViews()
        loadStart()
    }
    
    override func viewDidLayoutSubviews() {
        gradientLayer.frame = view.bounds
    }
    
    func permission(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        locationManager.requestLocation()
    }
    
    func registerViews() {
        forecastTableView.register(
            UINib(nibName: "TableViewCell", bundle: nil),
            forCellReuseIdentifier: "TableViewCell"
        )
        forecastTableView.register(
            UINib(nibName: "TableViewHeader", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "TableViewHeader"
        )
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            self.blur.frame = self.view.bounds
            self.errorView!.frame = self.view.bounds
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let tempUrl = buildUrl((manager.location?.coordinate.longitude)!, (manager.location?.coordinate.latitude)!)
        if url != tempUrl {
            url = tempUrl
            data.removeAll()
            loadForecastData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadError()
    }
    
    
    func buildUrl(_ longitude:Double, _ latitude:Double) -> String{
        return "https://api.openweathermap.org/data/2.5/forecast?lon=" + String(longitude) + "&lat=" + String(latitude) + "&appid=" + apiKey
    }
    
    
    func loadForecastData(){
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else { self!.loadError();return }
            guard (200 ..< 300) ~= httpResponse.statusCode else { self!.loadError();return }
            
            if let result = try? JSONDecoder().decode(ForecastResult.self, from: data) {
                for forecast in result.list {
                    let day = self!.formatter.weekdaySymbols[forecast.getDayIndex()]
                    if self!.data.isEmpty || self!.data[self!.data.count-1].header != day {
                        self!.data.append(SectionModel(header: day, cells: [RowModel]()))
                    }
                    self!.data[self!.data.count-1].cells.append(RowModel(icon: forecast.weather[0].getImage(), time: forecast.getTime(), temp: forecast.main.getTemperature(), weather: forecast.weather[0].description))
                }
                DispatchQueue.main.async {
                    self!.forecastTableView.reloadData()
                }
                self!.endError()
                self!.loadEnd()
            } else {
                self!.loadError()
            }
        }
        task.resume()
    }
    
    @IBAction func refreshForecast(_ sender: Any) {
        data.removeAll()
        loadStart()
        loadForecastData()
    }
    
    func handleReload() {
        refreshForecast(UIButton())
    }
    
    
    var blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    func loadStart(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        DispatchQueue.main.async {
            self.blur.frame = self.view.bounds
            self.view.addSubview(self.blur)
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.startAnimating();
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func loadEnd(){
        DispatchQueue.main.async {
            self.blur.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadError() {
        loadEnd()
        DispatchQueue.main.async {
            self.errorView!.frame = self.view.bounds
            self.view.addSubview(self.errorView!)
        }
    }
    
    func endError(){
        DispatchQueue.main.async { 
            self.errorView!.removeFromSuperview()
        }
    }
}

extension ForecastController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableViewHeader") as! TableViewHeader
        header.configure(self.data[section].header)
        return header
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 40
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self.data[section].cells.count
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let forecast = self.data[indexPath.section].cells[indexPath.row]
        cell.configure(forecast)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        viewForFooterInSection section: Int
    ) -> UIView? {
        return nil
    }

    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}


