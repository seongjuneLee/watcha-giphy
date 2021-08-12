//
//  GiphyCollectionViewCell.swift
//  watcha-giphy
//
//  Created by 이성준 on 2021/08/11.
//

import Foundation
import UIKit

class GiphyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func loadFileSync(indexPathItem : NSInteger, url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent("abcd\(indexPathItem)")
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            completion(destinationUrl.path, nil)
        }
        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                completion(destinationUrl.path, nil)
            }
            else
            {
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    func loadFileAsync(indexPathItem : NSInteger, url: URL, completion: @escaping (NSInteger?, String?, Error?) -> Void)
    {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.pathComponents[2])

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            completion(indexPathItem,destinationUrl.path, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(indexPathItem,destinationUrl.path, error)
                                }
                                else
                                {
                                    completion(indexPathItem,destinationUrl.path, error)
                                }
                            }
                            else
                            {
                                completion(indexPathItem,destinationUrl.path, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(indexPathItem,destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }

}
