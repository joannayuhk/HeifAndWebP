//
//  ImageFlowLayout.swift
//  HeifAndWebp
//
//  Created by Wesley Yang on 2017/10/19.
//  Copyright © 2017年 ff. All rights reserved.
//

import UIKit

private let rowMargin:CGFloat = 10;
private let colMargin:CGFloat = 10;
private let cols = 2;


class ImageFlowLayout: UICollectionViewLayout {
    
    var imageSizeArray : [CGSize]!
    
    private lazy var columnMaxYs : [CGFloat] = Array()
    private var attrsArray : [UICollectionViewLayoutAttributes] = Array()
    
    override var collectionViewContentSize: CGSize{
        var maxY:CGFloat = 0;
        for y in columnMaxYs {
            if(y > maxY) {
                maxY = y
            }
        }
        return CGSize.init(width: 0.0, height: maxY + rowMargin)
    }
    
    override func prepare() {
        super.prepare()
        
        columnMaxYs.removeAll();
        for _ in 0..<cols {
            columnMaxYs.append(rowMargin)
        }
        
        attrsArray.removeAll();
        
        let count = self.collectionView!.numberOfItems(inSection: 0);
        for i in 0..<count {
            let indexPath = IndexPath.init(item: i, section: 0)
            let attr = self.layoutAttributesForItem(at: indexPath);
            if let attr = attr {
                attrsArray.append(attr);
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
        let xMargin : CGFloat = colMargin * CGFloat(1+cols)
        let w = (self.collectionView!.frame.size.width - xMargin)/CGFloat(cols)
        
        let imgSize = imageSizeArray[indexPath.item]
        let h = w * imgSize.height/imgSize.width
        
        var minHeightCol = 0
        var minHeight = columnMaxYs[0]
        for i in 1..<cols {
            if(minHeight > columnMaxYs[i]){
                minHeight = columnMaxYs[i];
                minHeightCol = i;
            }
        }
        
        let x = colMargin + CGFloat(minHeightCol) * (w+colMargin)
        let y = minHeight + rowMargin;
        attrs.frame = CGRect.init(x: x, y: y, width: w, height: CGFloat(h));
        columnMaxYs[minHeightCol] = attrs.frame.maxY;
        return attrs;
    }
}
