
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
private let EMOJI_URL = "https://api.github.com/emojis"


extension String {
    func heightWithConstrained(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
}


class ViewController: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDataSourcePrefetching,
CHTCollectionViewDelegateWaterfallLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var datas = [EmojiModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // self.collectionView.register(HNACollectionViewCell.self, forCellWithReuseIdentifier: Identifier)
        
        let layout = HNAWaterfallLayout()
        layout.columnCount = COLUMNCOUNT
        layout.minimumColumnSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        collectionView.collectionViewLayout = layout
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
//        //** 正常方式*/
//        fetchData { (rstInfo) in
//            self.datas = self.dealData(rstInfo);
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//        }
        
        //** 链式调用*/
        fetchEmojis().done { (rstInfo) in
            self.datas = self.dealData(rstInfo);
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            }.catch { (error) in
                self.showAlert(error.localizedDescription)
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - <UICollectionViewDataSource,UICollectionViewDelegate>
    
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
    
    
    //MARK: - Private
    
    func dealData(_ json: Dictionary<String,Any>) -> Array<EmojiModel> {
        let width = ( UIScreen.main.bounds.width - CGFloat((COLUMNCOUNT + 1) * 5) ) / CGFloat(COLUMNCOUNT)
        let font = UIFont.systemFont(ofSize: 14)
        var items = [Dictionary<String,Any>]()
        
        for (name,value) in json {
            let height = name.heightWithConstrained(width: width, font: font)
            items.append(["name":name,"value":value,"height":height,"width":width])
        }
        
        let emojisModel:[EmojiModel] = items.map({EmojiModel($0)})
        return emojisModel
    }
    
    func showAlert(_ msg: String) {
        let alert = UIAlertController.init(title: "title", message: msg, preferredStyle: .alert)
        let confirmAction = UIAlertAction.init(title: "确定", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Datas fetch methods
    
    func fetchUrl() -> Promise <String> {
        let urlStr = EMOJI_URL
        return Promise { seal in
             seal.resolve(urlStr, nil)
        }
    }
    
    func fetchEmojis() -> Promise <Dictionary<String, Any>> {
        return Promise(resolver: { seal in
            Alamofire.request(EMOJI_URL).responseJSON(completionHandler: { (res) in
                switch res.result {
                case .success(let json):
                    return seal.resolve(json as! Dictionary,nil)
                case .failure(let error):
                    return seal.resolve(nil,error)
                }
            })
        })
    }
    
    func fetchData(completionHandler: @escaping (_ rstInfo : Dictionary<String, Any>) -> Swift.Void) {
        
        /*** 方法1*/
        Alamofire.request(EMOJI_URL).responseJSON { (response) in
            debugPrint("All Response Info: \(response)")
            switch response.result {
            case .success(let json):
                completionHandler(json as! Dictionary)
            case .failure(let error):
                self.showAlert(error.localizedDescription)
            }
        }
        
//        /*** 方法2*/
//        Alamofire.request(EMOJI_URL).responseJSON { (response) in
//            debugPrint("All Response Info: \(response)")
//            if let json = response.result.value {
//                completionHandler(json as! Dictionary<String, Any>)
//            }
//            //error ...
//        }
        
//        /*** 方法3*/
//        Alamofire.request(EMOJI_URL).responseData { response in
//            debugPrint("All Response Info: \(response)")
//            if let data = response.result.value, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
//                if JSONSerialization.isValidJSONObject(json) {
//                    completionHandler(json as! Dictionary)
//                }
//            }
//            //error ...
//        }
        
//        /*** 方法4*/
//        let task = URLSession.shared.dataTask(with: URL(string: EMOJI_URL)!) {
//            (Data, URLResponse, Error) in
//            if let json = try? JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String : AnyObject] {
//                if JSONSerialization.isValidJSONObject(json) {
//                    completionHandler(json)
//                }
//            }
//        }
//        task.resume()
        
    }
    
}

