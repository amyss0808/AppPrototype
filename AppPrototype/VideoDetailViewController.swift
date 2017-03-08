//
//  VideoDetailViewController.swift
//  AppPrototype
//
//  Created by 鍾妘 on 2017/2/22.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class VideoDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: Properties
    @IBAction func exit(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var videoDescription: UILabel!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoView: UIWebView!
    var videoId :Int = 0 {
        didSet{
            loadVideoDetail()
        }
    }
    
    
    //MARK: Default Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: Private Functions
    private func loadVideoDetail() {
        
        Alamofire.request("http://140.119.19.33:8080/SoslabProjectServer/video/\(videoId)").responseJSON { response in
            switch response.result {
            case .success(let value):
                
                let json = JSON(value)
                let youtubeId = json["youtube_id"].stringValue
                    
                DispatchQueue.main.async(execute: {
                    self.videoTitle.text = json["title"].stringValue
                    self.videoDescription.text = json["address"].stringValue
                    
                    self.videoView.allowsInlineMediaPlayback = true
                    self.videoView.loadHTMLString("<iframe width=\"\(self.videoView.frame.width)\" height=\"\(self.videoView.frame.height)\" src=\"https://www.youtube.com/embed/\(youtubeId)?playsinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
                })
                
                print(json)
            case .failure(let error):
                print(error)
            }
        }
        
        // video thumbnail reference:http://stackoverflow.com/questions/2068344/how-do-i-get-a-youtube-video-thumbnail-from-the-youtube-api/2068371#2068371
        
        Alamofire.request("http://album.s3.hicloud.net.tw/28199B/A.JPG?t=1488368005").response { response in
            if response.error == nil {
                if let data = response.data {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data, scale: 1 )
                    }
                }
            } else {
                print(response.error!)
            }
        }
    }
}


