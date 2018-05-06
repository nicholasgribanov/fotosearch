//
//  ViewController.swift
//  FootoSearch
//
//  Created by Николай Грибанов on 05.05.2018.
//  Copyright © 2018 Николай Грибанов. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textFIeld: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFIeld.delegate = self
        searchImage(text: "russia")
        textFIeld.becomeFirstResponder()
        imageView.layer.masksToBounds = true
    }
    func convert(farm: Int, server: String, id:String, secret: String) -> URL? {
        return URL(string:"https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_c.jpg")
    }
    
    func showError(text:String) {
        let alert = UIAlertController(title: "Упс...", message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    func showLoader(show:Bool){
        DispatchQueue.main.async {
            if(show){
                self.imageView.image = nil
            self.loader.startAnimating()
            }
            else {
                self.loader.stopAnimating()
            }
        }
    }
    
    func searchImage(text: String){
        showLoader(show: true)
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let key = "&api_key=154ca59f46d012b1959cf186fc724d2f"
        let format = "&format=json&nojsoncallback=1"
        let farmattedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let textToSearch = "&text=\(farmattedText)"
        let sort = "&sort=relevance"
        
        let searchUrl = base + key + textToSearch + sort + format;
        
        let url = URL(string: searchUrl)!
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let jsonData = data else{
                self.showLoader(show: false)
                self.showError(text:"Error, json is empty")
                return
            }
            guard let jsonAny = try? JSONSerialization.jsonObject(with: jsonData, options: []) else{
                self.showLoader(show: false)
                return
            }
            guard let json = jsonAny as? [String: Any] else {
                self.showLoader(show: false)
                return
            }
            
            guard let photos = json["photos"] as? [String: Any] else {
                self.showLoader(show: false)
                return
            }
            
            guard let photosArray = photos["photo"] as? [Any] else {
                self.showLoader(show: false)
                return
            }
            
            guard photosArray.count > 0 else {
                self.showLoader(show: false)
                self.showError(text:"Photos is empty")
                return
            }
            guard let firstPhoto = photosArray[0] as? [String: Any] else {
                self.showLoader(show: false)
                return
            }
            let farm = firstPhoto["farm"] as! Int
            let id = firstPhoto["id"] as! String;
            let secret = firstPhoto["secret"] as! String;
            let server = firstPhoto["server"] as! String;
            
            let pictureUrl = self.convert(farm: farm, server: server, id: id, secret: secret)
            
            URLSession.shared.dataTask(with: pictureUrl!, completionHandler: { (data, _, _) in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data:data!)
                }
                self.showLoader(show: false)
            }).resume()
        }.resume()
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchImage(text: textField.text!)
        return true
    }
}

