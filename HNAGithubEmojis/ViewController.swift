
//  ViewController.swift
//  HNAGithubEmojis
//
//  Created by __无邪_ on 2017/9/4.
//  Copyright © 2017年 __无邪_. All rights reserved.
//

import UIKit
import SDWebImage

let Identifier = "Identifier"

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDataSourcePrefetching {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var datas = [Dictionary<String, Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        self.collectionView.register(HNACollectionViewCell.self, forCellWithReuseIdentifier: Identifier)
        
        getData { (items) in
            self.datas = items as! [Dictionary<String, Any>]
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
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
        cell.backgroundColor = UIColor.lightGray
        print(cell.imageView)
        cell.titleLabel.text = data["name"] as? String
        
        cell.imageView.sd_setImage(with: URL.init(string: data["value"] as! String), completed: nil)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]){
//        NSLog("===== \(indexPaths)")
    }
    
    
    //MARK: - Private methods
    
    func getData(completionHandler: @escaping (_ version : Array<Any>) -> Swift.Void) {
        let task = URLSession.shared.dataTask(with: URL(string: "https://api.github.com/emojis")!) {
            (Data, URLResponse, Error) in
            
            if let json = try? JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as! [String : AnyObject] {
                if JSONSerialization.isValidJSONObject(json) {
                    
                    var items = [Dictionary<String,Any>]()
                    for (name,value) in json {
                        items.append(["name":name,"value":value])
                    }
                    completionHandler(items)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    
    
    


}

