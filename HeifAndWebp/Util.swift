//
//  Util.swift
//  HeifAndWebp
//
//  Created by Wesley Yang on 2017/10/19.
//  Copyright © 2017年 ff. All rights reserved.
//

import UIKit
import AVFoundation
import YYImage

class Util: NSObject {
    public static func sizeOfImage(imgPath:String) -> CGSize{
        let url = NSURL.init(fileURLWithPath: imgPath)
        let source = CGImageSourceCreateWithURL(url, nil)
        if let source = source {
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as NSDictionary?
            
            if let property = properties {
                let width = property[kCGImagePropertyPixelWidth] as! NSNumber
                let height = property[kCGImagePropertyPixelHeight] as! NSNumber
                return CGSize.init(width: width.intValue, height: height.intValue)
            }
        }else{
            print("file not found " + imgPath)
        }
        return CGSize.init(width: 0, height: 0)
    }
    
    public static func diskSizeOfFile(path:String) -> UInt64 {
        var fileSize : UInt64 = 0
        do {
            let attr : NSDictionary? = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            if let _attr = attr {
                fileSize = _attr.fileSize()
                print(fileSize)
            }
        } catch {
        }
        return fileSize
    }
    
    public static func heifDataOfImage(image:UIImage,quality:Float) -> NSData?{
        if #available(iOS 11.0, *) {

            let destData = NSMutableData()
            let destination = CGImageDestinationCreateWithData(destData, AVFileType.heic as CFString, 1, nil)
            
            guard let dest = destination else {return nil};
            let options = [kCGImageDestinationLossyCompressionQuality:quality]
            CGImageDestinationAddImage(dest, image.cgImage!, options as CFDictionary)
            CGImageDestinationFinalize(dest)
            print(destData.length)
            return destData
        }else {
            return nil;
        }
    }
    
    public static func webpDataOfImage(image:UIImage,quality:Float) -> Data?{
        let encoder = YYImageEncoder.init(type: YYImageType.webP)
        encoder?.quality = CGFloat(quality)
        encoder?.add(image, duration: 0)
        let data = encoder?.encode()
        return data
    }
}
