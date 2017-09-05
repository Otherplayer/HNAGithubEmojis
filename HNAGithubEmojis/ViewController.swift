
//  ViewController.swift
//  HNAGithubEmojis
//
//  Created by __无邪_ on 2017/9/4.
//  Copyright © 2017年 __无邪_. All rights reserved.
//

import UIKit
import SDWebImage
import CHTCollectionViewWaterfallLayout
import Alamofire
import PromiseKit

private let Identifier = "Identifier"
private let COLUMNCOUNT = 6



extension String {
    func heightWithConstrained(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return boundingBox.height
    }
}


class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDataSourcePrefetching,CHTCollectionViewDelegateWaterfallLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var datas = [EmojiModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.collectionView.register(HNACollectionViewCell.self, forCellWithReuseIdentifier: Identifier)
        
        let layout = HNAWaterfallLayout()
        layout.columnCount = COLUMNCOUNT
        layout.minimumColumnSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        collectionView.collectionViewLayout = layout
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /// 链式调用
        fetchUrl().then { urlStr in
            return self.fetchEmojis(url: urlStr)
            }.then { items -> Void in
                self.datas = items
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }.catch { error in
                print(error)
        }
        fetch().then { result in
            print("result\(result)")
            }.catch { (error) in
                print(error)
        }
//        fetchEmojis().then { (items) -> Void in
//            self.datas = items
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//            }.catch { (err) in
//                print(err)
//        }
        
//        getData { (items) in
//            self.datas = items
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: -
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NSLog("Cell at : \(indexPath.row) was selected")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.datas.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = self.datas[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier, for: indexPath) as! HNACollectionViewCell
        
        cell.titleLabel.text = data.name
        cell.imageView.sd_setImage(with: URL.init(string: data.value!), completed: nil)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]){
        // NSLog("===== \(indexPaths)")
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let data = self.datas[indexPath.row]
        let width = data.width
        let height = data.height
        return CGSize(width: width, height: height + width)
    }
    
    //MARK: - PromiseKit
    func fetch(completion: (String) -> Void) {
        completion("callback exe")
    }
    func fetch() -> Promise<String> {
        return PromiseKit.wrap(fetch)
    }
    
    //MARK: - Datas fetch methods
    
    func fetchUrl() -> Promise<String> {
        let urlStr = "https://api.github.com/emojis"
        return Promise { fulfill, reject in
            fulfill(urlStr)
        }
    }
    
    func fetchEmojis(url urlStr: String) -> Promise <[EmojiModel]> {
        let width = ( UIScreen.main.bounds.width - CGFloat((COLUMNCOUNT + 1) * 5) ) / CGFloat(COLUMNCOUNT)
        let font = UIFont.systemFont(ofSize: 14)
//        let urlStr = "https://api.github.com/emojis"
        
        return Promise { fulfill, reject in
            Alamofire.request(urlStr).responseJSON(completionHandler: { (res) in
                switch res.result {
                case .success(let json):
                    var items = [Dictionary<String,Any>]()
                    for (name,value) in json as! [String : AnyObject] {
                        let height = name.heightWithConstrained(width: width, font: font)
                        items.append(["name":name,"value":value,"height":height,"width":width])
                    }
                    
                    let emojisModel:[EmojiModel] = items.map({EmojiModel($0)})
                    fulfill(emojisModel)
                case .failure(let error):
                    return reject(error)
//                default:
//                    return reject(PMKError.invalidCallingConvention)
                }
            })
        }
    }
    
    func getData(completionHandler: @escaping (_ version : Array<EmojiModel>) -> Swift.Void) {
        
        let width = ( UIScreen.main.bounds.width - CGFloat((COLUMNCOUNT + 1) * 5) ) / CGFloat(COLUMNCOUNT)
        let font = UIFont.systemFont(ofSize: 14)
        let urlStr = "https://api.github.com/emojis"
        
        
        Alamofire.request(urlStr).responseJSON { (response) in
            debugPrint(response)
            switch response.result {
            case .success(let json):
                var items = [Dictionary<String,Any>]()
                for (name,value) in json as! [String : AnyObject] {
                    let height = name.heightWithConstrained(width: width, font: font)
                    items.append(["name":name,"value":value,"height":height,"width":width])
                }
                
                let emojisModel:[EmojiModel] = items.map({EmojiModel($0)})
                
                completionHandler(emojisModel)
                
            case .failure(let error):
                print(error)
                
//                let alert = UIAlertController.init(title: "title", message: "msg", preferredStyle: .actionSheet)
//                alert.promise().then { buttonIndex in
//                    print("ok \(buttonIndex)")
//                }
            }
        }
        
        /*** 方法1*/
//        Alamofire.request(urlStr).responseData { response in
//            debugPrint("All Response Info: \(response)")
//            if let data = response.result.value, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject] {
//                if JSONSerialization.isValidJSONObject(json) {
//                    var items = [Dictionary<String,Any>]()
//                    for (name,value) in json {
//                        let height = name.heightWithConstrained(width: width, font: font)
//                        items.append(["name":name,"value":value,"height":height,"width":width])
//                    }
//                    completionHandler(items)
//                }
//            }
//        }
        
//        Alamofire.request(urlStr).responseJSON { (response) in
//            debugPrint(response)
//            if let json = response.result.value {
//                print("JSON: \(json)")
//                var items = [Dictionary<String,Any>]()
//                for (name,value) in json as! [String : AnyObject] {
//                    let height = name.heightWithConstrained(width: width, font: font)
//                    items.append(["name":name,"value":value,"height":height,"width":width])
//                }
//                completionHandler(items)
//            }
//        }
        
        
        
        /*** 方法2*/
//        let task = URLSession.shared.dataTask(with: URL(string: urlStr)!) {
//            (Data, URLResponse, Error) in
//
//            if let json = try? JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String : AnyObject] {
//                if JSONSerialization.isValidJSONObject(json) {
//
//                    var items = [Dictionary<String,Any>]()
//                    for (name,value) in json {
//                        let height = name.heightWithConstrained(width: width, font: font)
//                        items.append(["name":name,"value":value,"height":height,"width":width])
//                    }
//                    completionHandler(items)
//
//                }
//            }
//        }
//        task.resume()
        
        
    }
    
    
    
    
    
    
    


}

