//
//  VC.swift
//  Athena
//
//  Created by Aalap Patel on 9/15/18.
//  Copyright © 2018 Jamal Rasool. All rights reserved.
//

import UIKit

class VC: UITableViewController {
    
    @IBOutlet weak var suggestionsTableViewController: UITableView!
    
    var houseSuggestionsList = [suggestList]() //Array of dictionary

//    struct suggstObj: Decodable {
//        let suggestListT: [suggestList]!
//
//        public enum CodingKeys: String, CodingKey {
//            case suggestListT = "suggestions"
//        }
//    }
    
    struct suggestList: Decodable {
        let bed: Int!
        let bld_id: Int!
        let location: String!
        let picture_urls: String!
        let price: Int!
    
        public enum CodingKeys: String, CodingKey {
            case bed = "bed"
            case bld_id = "bath"
            case location = "location"
            case picture_urls = "picture_urls"
            case price = "price"
        }
    }
    

    fileprivate func fetchJSON() {
        let urlString = "http://35.211.54.164:8000/suggestions/1"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    print("Failed to get data from url:", err)
                }
                guard let data = data else { return }
                
                do {
                    // link in description for video on JSONDecoder
                    let decoder = JSONDecoder()

                    var converterHandler = try decoder.decode([suggestList].self, from: data)
                    print(converterHandler)

                    self.houseSuggestionsList = converterHandler
                    self.houseSuggestionsList.count

                    self.suggestionsTableViewController.reloadData()

                } catch let jsonErr {
                    print("Failed to decode:", jsonErr)

                    return
                }
            }
            }.resume()
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        fetchJSON()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 250
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Yeets(_ sender: Any) {
        
        let vc = ARController()
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
            return nil
        }
        return indexPath
    }
    
   
    
}

class CustomCell: UITableViewCell {
    

    
    @IBOutlet weak var thumbImageView: UIImageView! // Picture URL
    @IBOutlet weak var infoLabel: UILabel!  // Location
    @IBOutlet weak var priceLabel: UILabel! // Price Handler
    @IBOutlet weak var descriptionLabel: UILabel! // Bedroom, Bathroom
    
}

extension VC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return houseSuggestionsList.count
    }
    
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let house = houseSuggestionsList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
//         Text Information
        cell.priceLabel.text = "$\(String(describing: house.price!))"
        cell.infoLabel.text = house.location
        cell.descriptionLabel.text = "\(String(describing: house.bed!)) Bed  \(String(describing: house.bld_id!)) Bath 2500sqft"


        // Image Handler
        let imageURL = house.picture_urls
        let url = URL(string: imageURL!)

        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else { return }

            DispatchQueue.main.async() {    // execute on main thread
                cell.thumbImageView.image = UIImage(data: data)
            }
        }
        
        task.resume()

        
        cell.clipsToBounds = true
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



/**
 
Settings Class
 
 
 */

class SettingsVC: UITableViewController {
    
    @IBOutlet weak var sampleViewC: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
            return nil
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func go_back(_ sender: Any) {
        let vc = ARController()
        self.present(vc, animated: true, completion: nil)
    }

    
}
