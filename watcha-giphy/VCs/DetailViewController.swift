//
//  DetailViewController.swift
//  DetailViewController
//
//  Created by 이성준 on 2021/08/11.
//

import Foundation
import SwiftUI

class DetailViewController: UIViewController {
    
    var favoriteURLs = NSMutableArray()
    var currentURL = String()
    var image = UIImage()
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if UserDefaults.standard.object(forKey: "favoriteURLs") == nil {
            self.favoriteURLs = NSMutableArray.init()
        } else {
            self.favoriteURLs = NSMutableArray.init(array: UserDefaults.standard.object(forKey: "favoriteURLs") as! Array<String>)
        }
        self.imageView.image = self.image
        if (self.favoriteURLs.contains(self.currentURL)) {
            self.favoriteButton.isSelected = true
            self.favoriteButton.setImage(UIImage.init(named: "favoriteFilled"), for: UIControl.State.selected)
        }
        
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setImage(UIImage.init(named: "favoriteFilled"), for: UIControl.State.selected)
            self.favoriteURLs.add(self.currentURL)
            UserDefaults.standard.setValue(self.favoriteURLs, forKey: "favoriteURLs")
        } else {
            sender.setImage(UIImage.init(named: "favorite"), for: UIControl.State.normal)
            self.favoriteURLs.remove(self.currentURL)
            UserDefaults.standard.setValue(self.favoriteURLs, forKey: "favoriteURLs")
            
        }
        
    }
    
}
