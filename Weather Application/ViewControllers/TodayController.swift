//
//  TodayController.swift
//  Weather Application
//
//  Created by DimitriAdeishvili on 2/1/21.
//

import UIKit
import CoreLocation
import UPCarouselFlowLayout

var longitude: Double? = nil
var latitude: Double? = nil
var todayPath = ""

class TodayController: UIViewController, CLLocationManagerDelegate, ErrorViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popup: UIView!
    @IBOutlet var add: UIButton!
    @IBOutlet var addPop: UIButton!
    @IBOutlet var txt: UITextField!
    @IBOutlet var err: UIView!
    @IBOutlet var const: NSLayoutConstraint!
    let usdef = UserDefaults.standard
    @IBOutlet weak var pageControl: UIPageControl!
    var dataSource: [CollectionCellModel] = []
    
    var position = true
    var errorView: ErrorView? = ErrorView()
    let gradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [
                UIColor(named: "bg-gradient-start")?.cgColor ?? UIColor.blue.cgColor ,
                UIColor(named: "bg-gradient-end")?.cgColor ?? UIColor.red.cgColor
            ]
            return layer
        }()
    
    
    let layout = UPCarouselFlowLayout()
    var url = "https://openweathermap.org/current"
    var currentIndex = 0
    let apiKey = "f1c7f5b840d872080e69d492085a4430"
    var locationManager = CLLocationManager()
    
    let popupLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [
                UIColor(named: "green-gradient-start")?.cgColor ?? UIColor.blue.cgColor ,
                UIColor(named: "green-gradient-end")?.cgColor ?? UIColor.red.cgColor
            ]
            return layer
        }()
    
    let cityLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [
                UIColor(named: "blue-gradient-start")?.cgColor ?? UIColor.blue.cgColor ,
                UIColor(named: "blue-gradient-end")?.cgColor ?? UIColor.red.cgColor
            ]
            return layer
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.collectionView.addGestureRecognizer(longPressRecognizer)
        
        if let data = usdef.object(forKey: "cities") as? Data {
            let decoder = JSONDecoder()
            if let arr = try? decoder.decode([CollectionCellModel].self, from: data) {
                self.dataSource = arr
            }
        }
        err.layer.cornerRadius = 20
        popup.layer.cornerRadius = 20
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: collectionView.bounds.width * 0.7, height: collectionView.bounds.height)
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.backgroundImage = UIImage()
        
        popupLayer.frame = popup.bounds
        popupLayer.cornerRadius = 20
        popup.layer.insertSublayer(popupLayer, at: 0)
        gradientLayer.frame = view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        errorView?.delegate = self
        permission()
        loadBlur()
        
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        self.collectionView.cellForItem(at: IndexPath(row: 0, section: self.currentIndex))
        
            let alertActionCell = UIAlertController(title: "Do you want to delete this city", message: "Choose an action", preferredStyle: .actionSheet)

            
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                //RecipeDataManager.shared.recipes.remove(at: indexPath!.row)
                self.dataSource.remove(at: self.currentIndex)
                
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self.dataSource) {
                    self.usdef.set(encoded, forKey: "cities")
                }
                self.collectionView.reloadData()
            })

            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            })

            alertActionCell.addAction(deleteAction)
            alertActionCell.addAction(cancelAction)
            self.present(alertActionCell, animated: true, completion: nil)

        
    }
    
    override func viewDidLayoutSubviews() {
        gradientLayer.frame = view.bounds
        add.layer.cornerRadius = add.frame.height/2
        addPop.layer.cornerRadius = addPop.frame.height/2
    }
    
    @IBAction private func addCity(){
        collectionView.isHidden = true
        add.isHidden = true
        popup.isHidden = false
    }
    @IBAction private func add2(){
        let tempUrl = buildUrlCity(txt.text!)
        print(tempUrl)
        if url != tempUrl {
            url = tempUrl
            loadStart()
            loadCurrentData(url) { bool in
                if bool {
                    self.loadEnd()
                    self.endError()
                    self.endBlur()
                } else {
                    self.loadError()
                }
            }
        }
        popup.isHidden=true
        collectionView.isHidden = false
        add.isHidden = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        position.toggle()
        self.dataSource = self.dataSource.map({ CollectionCellModel(middlePosition: position, cloudness: $0.cloudness, humidity: $0.humidity, speed: $0.speed, degree: $0.degree, image: $0.image, location: $0.location, weather: $0.weather) })
        DispatchQueue.main.async {
            self.blur.frame = self.view.bounds
            self.errorView!.frame = self.view.bounds
            self.collectionView.reloadData()
        }
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
    
    var allowed: Bool = false
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        loadError()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        allowed = true
        let tempUrl = buildUrl((manager.location?.coordinate.longitude)!, (manager.location?.coordinate.latitude)!)
        if let data = usdef.object(forKey: "cities") as? Data {
            let decoder = JSONDecoder()
            if let arr = try? decoder.decode([CollectionCellModel].self, from: data) {
                self.dataSource = arr
            }
        }
        if url != tempUrl && self.dataSource.isEmpty{
            url = tempUrl
            loadStart()
            loadCurrentData(url) { bool in
                if bool {
                    self.loadEnd()
                    self.endError()
                    self.endBlur()
                } else {
                    self.loadError()
                }
            }
        } else {
            self.loadEnd()
            self.endError()
            self.endBlur()
        }
    }
    
    func buildUrl(_ longitude:Double, _ latitude:Double) -> String{
        return "https://api.openweathermap.org/data/2.5/weather?lon=" + String(longitude) + "&lat=" + String(latitude) + "&appid=" + apiKey
    }
    
    func buildUrlCity(_ city: String) -> String{
        return "https://api.openweathermap.org/data/2.5/weather?q=" + city +  "&appid=" + apiKey
    }
    func configureSpeed(speed: CurrentWind ) -> String {
        return String(round(speed.speed)) + " km/h"
    }
        
    func configureDegree(deg : CurrentWind) -> String {
        return Direction(deg.deg).description
    }

    func configureCloudness(all: CurrentClouds) -> String {
        return String(round(all.all)) + " %"
    }
        
    func configureCountry(country: CurrentSys) -> String {
        return ", " + country.country.uppercased()
    }

    func configureTemperature(temp: CurrentMain) -> String {
        return String(round(temp.temp-273.15)) + "˚C | "
    }
        
    func configureHumidity(humidity: CurrentMain) -> String {
        return String(round(humidity.humidity)) + " mm"
    }

    func configureImage(icon: CurrentWeather) -> UIImage {
        if let data = try? Data(contentsOf:URL(string: "https://openweathermap.org/img/wn/" + icon.icon + "@2x.png")!) {
            if let image = UIImage(data: data) {
                return image
            }}
        return UIImage(named: "cloud")!
    }
    
    func loadCurrentData(_ url: String, _ completion: @escaping ((Bool) -> Void)){
        let enc = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        var request = URLRequest(url: URL(string: enc)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {self!.loadError();return }
            guard (200 ..< 300) ~= httpResponse.statusCode else { self!.loaderr();return }
            
            if let result = try? JSONDecoder().decode(CurrentResult.self, from: data) {
                self?.dataSource.append(CollectionCellModel(middlePosition: self!.position,
                                                            cloudness: self!.configureCloudness(all: result.clouds),
                                                            humidity: self!.configureHumidity(humidity: result.main),
                                                            speed: self!.configureSpeed(speed: result.wind),
                                                            degree: self!.configureDegree(deg: result.wind),
                                                            image: self!.configureImage(icon: result.weather[0]).pngData()!,
                                                            location: result.name + (self?.configureCountry(country: result.sys))!,
                                                            weather: self!.configureTemperature(temp: result.main) + result.weather[0].main))
                DispatchQueue.main.async {
                    self!.collectionView.reloadData()
                    self!.txt.text = ""
                }
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self!.dataSource) {
                    self!.usdef.set(encoded, forKey: "cities")
                }
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    
    
    @IBAction func refreshToday(_ sender: Any) {
        loadBlur()
        loadStart()
        let dataSourceCopy = self.dataSource
        self.dataSource.removeAll()
        let dsp = DispatchGroup()
        for data in dataSourceCopy {
            dsp.enter()
            let ind = data.location.firstIndex(of: ",")
            let pref = data.location.prefix(upTo: ind!)
            let url = buildUrlCity(String(pref))
            loadCurrentData(url) { bool in
                dsp.leave()
            }
        }
        dsp.wait()
        self.loadEnd()
        self.endError()
        self.endBlur()
    }
    
    func handleReload() {
        refreshToday(UIButton())
    }
    
    
    var blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    func loadStart(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        DispatchQueue.main.async {
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.startAnimating();
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func loadEnd(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func loadBlur() {
        DispatchQueue.main.async {
            self.blur.frame = self.view.bounds
            self.view.addSubview(self.blur)
        }
    }
    
    func endBlur(){
        DispatchQueue.main.async {
            self.blur.removeFromSuperview()
        }
    }
    
    func loaderr(){
        DispatchQueue.main.async {
            self.txt.text = ""
            UIView.animate(withDuration: 1, animations: {
                self.const.constant = 30
                self.view.layoutIfNeeded()
                self.loadEnd()
            })
            UIView.animate(withDuration: 1, delay: 3 ,animations: {
                self.const.constant = -300
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func loadError() {
        endBlur()
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


extension TodayController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let num = self.dataSource.count
        pageControl.numberOfPages = num
        pageControl.isHidden = !(num > 1)
        return num
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        cityLayer.frame = cell.bounds
        cityLayer.cornerRadius = 20
        cell.layer.insertSublayer(cityLayer, at: 0)
        cell.configure(self.dataSource[indexPath.section])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.section
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = self.collectionView.indexPath(for: self.collectionView.visibleCells.first!)!.section
    }
    
    
}
