//
//  ViewController.swift
//  watcha-giphy
//
//  Created by 이성준 on 2021/08/11.
//

import SwiftUI
import GiphyUISDK
import Alamofire

class SearchViewController: UIViewController {

    @IBOutlet weak var gifsButton: UIButton!
    @IBOutlet weak var stickersButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    var lastKeyword = String()
    
    var urls = NSMutableArray()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.register(UINib.init(nibName: "GiphyCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier:"GiphyCollectionViewCell")
        self.requestWithEndPoint(endPoint: "trending", keyword: "")
        self.searchBar.delegate = self
        
    }
    
    func setCollectionViewFlowLayout() {
        
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let availableWidthForCells = self.view.frame.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * 1
        let cellWidth = availableWidthForCells
        flowLayout.itemSize = CGSize.init(width: cellWidth, height: cellWidth)
        
    }
    
    
    func requestWithEndPoint(endPoint : NSString, keyword : String) {
        
        self.urls = NSMutableArray.init()

        let base = "https://api.giphy.com/v1/"
        var type = ""
        if self.gifsButton.isSelected {
            type = "gifs"
        } else {
            type = "stickers"
        } 
        let url = base.appending("\(type)/\(endPoint)")
        var parameters = [String : Any]()
        parameters["api_key"] = "bEPStQt5o0hLfjrwbx8cxkmcpIBSeCHr"
        if endPoint.isEqual(to: "search") {
            parameters["q"] = keyword
        }
        parameters["limit"] = 50
        let request = AF.request(url, parameters: parameters)
        request.responseJSON { (data) in
            switch data.result {
            case .success(let value as [String : Any]):
                let datas = value["data"] as! Array<[String : Any]>
                for dict in datas {
                    let images = dict["images"] as! [String : Any]
                    let image = images["fixed_height"] as! [String : Any]
                    
                    let url = URL(string: image["url"] as! String)
                    self.urls.add(url ?? "")
                }
                self.collectionView.reloadData()
            case .failure(let error):
                print("value data : ",error)
            default:
                fatalError("received non-dictionary JSON response")
            }
        }
        
    }

    @IBAction func gifsButtonTapped(_ sender: UIButton) {
        
        if !sender.isSelected {
            
            sender.isSelected = true
            self.stickersButton.isSelected = false
            
            sender.alpha = 1.0
            self.stickersButton.alpha = 0.4
            
            // 키워드가 검색된 상태면 키워드 반영해주기 위해
            if self.lastKeyword.count > 0 {
                self.requestWithEndPoint(endPoint: "search", keyword: self.lastKeyword )
            } else {
                self.requestWithEndPoint(endPoint: "trending", keyword: "")
            }
        }
    }
    
    @IBAction func stickersButtonTapped(_ sender: UIButton) {

        if !sender.isSelected {
            
            sender.isSelected = true
            self.gifsButton.isSelected = false
            
            sender.alpha = 1.0
            self.gifsButton.alpha = 0.4
            if self.lastKeyword.count > 0 {
                self.requestWithEndPoint(endPoint: "search", keyword: self.lastKeyword )
            } else {
                self.requestWithEndPoint(endPoint: "trending", keyword: "")
            }
        }

    }
        
    
}

extension SearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 {
            self.placeHolderLabel.isHidden = true
        } else {
            self.placeHolderLabel.isHidden = false
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count ?? 0 > 0 {
            self.requestWithEndPoint(endPoint: "search", keyword: searchBar.text ?? "")
        } else {
            self.requestWithEndPoint(endPoint: "trending",keyword:"")
        }
        self.lastKeyword = searchBar.text ?? ""
        searchBar.resignFirstResponder()
    }
    
}

extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.urls.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiphyCollectionViewCell", for: indexPath) as! GiphyCollectionViewCell

        let url = self.urls[indexPath.item] as! URL

        cell.loadFileAsync(indexPathItem: indexPath.item, url: url) { (completedIndexPathItem ,path, error) in
            let data = self.getDataFromPath(path: path ?? "")
            DispatchQueue.main.async {
                if completedIndexPathItem == indexPath.item {
                    cell.gifImageView.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: self.view.frame.width/2 - 10, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        
        let cell = collectionView.cellForItem(at: indexPath) as! GiphyCollectionViewCell
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let detailVC = mainStoryBoard.instantiateViewController(identifier: "DetailViewController") as DetailViewController
        
        detailVC.image = cell.gifImageView.image ?? UIImage()
        let url = self.urls[indexPath.item] as! URL
        detailVC.currentURL = url.absoluteString
        
        self.navigationController?.pushViewController(detailVC, animated: true)
        

    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    func getDataFromPath(path : String) -> Data {
        if FileManager.default.fileExists(atPath: path){
            if let cert = NSData(contentsOfFile: path) {
                return cert as Data
            }
        }
        return Data.init()
    }


}
