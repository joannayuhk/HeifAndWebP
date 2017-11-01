//
//  ImageListViewController.swift
//  HeifAndWebp
//
//  Created by Wesley Yang on 2017/10/19.
//  Copyright © 2017年 ff. All rights reserved.
//

import UIKit

private let reuseIdentifier = "cell"

class ImageListViewController: UICollectionViewController {
    
    var imgPathArray:[String]!
    var sizeArray:[CGSize]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let resourcePath = Bundle.main.bundlePath.appending("/res/origin")
        let files = try! FileManager.default.contentsOfDirectory(atPath: resourcePath)
        imgPathArray = files.map({ (s) -> String in
            resourcePath.appendingFormat("/%@", s)
        })
        
        sizeArray = [CGSize]()
        for p in imgPathArray {
            let size = Util.sizeOfImage(imgPath: p)
            sizeArray.append(size)
        }
        
        let layout = self.collectionView?.collectionViewLayout as! ImageFlowLayout
        layout.imageSizeArray = sizeArray

    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let cell = sender! as? UICollectionViewCell , let vc = segue.destination as? DetailViewController {
            let idx = cell.tag
            let path = imgPathArray[idx]
            vc.filePath = path
        }
        
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgPathArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let imageView = cell.viewWithTag(2) as? UIImageView
        let textLabel = cell.viewWithTag(1) as? UILabel
        let imagePath = imgPathArray[indexPath.item]
        let imageSize = sizeArray[indexPath.item]
        if let imageView = imageView {
            imageView.image = UIImage.init(contentsOfFile:imagePath)
        }
        if let textLabel = textLabel {
            textLabel.text = " \(Int(imageSize.width)) x \(Int(imageSize.height)) "
        }
        cell.tag = indexPath.row
        // Configure the cell
        return cell
    }
    

}
