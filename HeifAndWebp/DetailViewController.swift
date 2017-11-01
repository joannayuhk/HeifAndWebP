//
//  DetailViewController.swift
//  HeifAndWebp
//
//  Created by Wesley Yang on 2017/10/19.
//  Copyright © 2017年 ff. All rights reserved.
//

import UIKit
import YYImage
import SimpleImageViewer

class DetailViewController: UIViewController {

    var filePath : String!
    var fileDiskSize : UInt64!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sliderTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fileDiskSize = Util.diskSizeOfFile(path: filePath)
        
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(DetailViewController.doImageTapped(_:)))
        imageView.addGestureRecognizer(tap)
        updateView()
    }
    
    @objc func doImageTapped(_ sender: UIGestureRecognizer) {
        let configuration = ImageViewerConfiguration { config in
            config.image = imageView.image
        }
        let vc = ImageViewerController.init(configuration: configuration)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func doSegmentChanged(_ sender: UISegmentedControl) {
        updateView();
    }
    
    @IBAction func doSliderChanged(_ sender: UISlider) {
        updateOnQualityChange()
    }
    
    func updateOnQualityChange() {
        let oriImage = UIImage.init(contentsOfFile: filePath)
        sliderTextLabel.text = "Quality:\(sliderValue())"
        
        if isShowingWebp() {
            let startTime = Date()
            let webpData = Util.webpDataOfImage(image: oriImage!, quality: sliderValue())
            let time1 = Date()
            guard let webpData2 = webpData else {return}
            imageView.image = YYImage.image(with: webpData2)
            let time2 = Date()
            textLabel.text = """
            OriginSize:\(Float(fileDiskSize!)/1024.0)KB
            Current:\(Float(webpData2.count)/1024.0)KB
            Encoding:\(Int(time1.timeIntervalSince(startTime)*1000))ms
            Display:\(Int(time2.timeIntervalSince(time1)*1000))ms
            """
            
        }else if isShowingHeif(){
            let startTime = Date()
            let heifData = Util.heifDataOfImage(image: oriImage!, quality: sliderValue())
            let time1 = Date()
            guard let heifData2 = heifData else {
                textLabel.text = "HEIF encoding not supported"
                return
            }
            let source = CGImageSourceCreateWithData(heifData2, nil)
            let cgImage = CGImageSourceCreateImageAtIndex(source!, 0, nil)
            let uiImage = UIImage.init(cgImage: cgImage!)
            imageView.image = uiImage
            let time2 = Date()
            textLabel.text = """
            OriginSize:\(Float(fileDiskSize!)/1024.0)KB
            Current:\(Float(heifData2.length)/1024.0)KB"
            Encoding:\(Int(time1.timeIntervalSince(startTime)*1000))ms
            Display:\(Int(time2.timeIntervalSince(time1)*1000))ms
            """

        }
    }
    
    func isShowingWebp() -> Bool {
        let idx = segment.selectedSegmentIndex
        return idx == 1
    }
    
    func isShowingHeif() -> Bool {
        let idx = segment.selectedSegmentIndex
        return idx == 2
    }
    
    func sliderValue() -> Float {
        return Float(Int(slider.value * 100))/100
    }
    
    func updateView() {
        imageView.image = nil
        textLabel.text = ""
        
        let imgName = ((filePath as NSString).lastPathComponent as NSString).deletingPathExtension
        let idx = segment.selectedSegmentIndex
        let folder = ["origin","webp","heif"][idx]
        let surffix = ["","webp","heic"][idx]
        var fullPath : String
        if idx == 0 {
            fullPath = filePath
        }else{
            fullPath = ((filePath as NSString).deletingLastPathComponent as NSString).deletingLastPathComponent.appending("/\(folder)/\(imgName).\(surffix)")
        }
        if surffix == "heic" {
            let url = URL.init(fileURLWithPath: fullPath)
            let source = CGImageSourceCreateWithURL(url as CFURL, nil)
            if let source = source {
                let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
                if let cgImage = cgImage {
                    imageView.image = UIImage(cgImage: cgImage)
                }
            }else{
                updateOnQualityChange()
            }
        }else{
            imageView.image = YYImage.image(withContentsOfFile: fullPath)
            if imageView.image == nil {
                updateOnQualityChange()
            }
        }
        
        let showSlider = isShowingHeif() || isShowingWebp()
        slider.isHidden = !showSlider
        sliderTextLabel.isHidden = !showSlider
       
    }

}
