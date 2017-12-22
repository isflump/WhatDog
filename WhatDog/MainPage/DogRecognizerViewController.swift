//
//  ViewController.swift
//  WhatDog
//
//  Created by Ryan Yan on 12/21/17.
//

import UIKit
import AVFoundation
import SnapKit

class DogRecognizerViewController: UIViewController, AVFrameExtractorDelegate, DogClassifierDelegate {
    
    let preview = AVCapturePreview()
    var dogTypeLabel = UILabel()
    var dogLabelContainer = UIView()

    lazy var frameExtractor = AVFrameExtractor()
    lazy var dogClassifier = DogClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup(){
        frameExtractor.delegate = self
        dogClassifier.delegate = self
        setupAVPreview()
    }
    
    private func setupAVPreview(){
        preview.backgroundColor = UIColor.black
        self.view.addSubview(preview)
        preview.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        preview.session = frameExtractor.captureSession
    }
    
    // MARK : AVFrameExtractorDelegate
    func captured(image: UIImage){
        dogClassifier.updateClassifications(for: image)
    }
    
    // MARK :DogClassifierDelegate
    func didFinishClassificationWith(dogType: String?) {
        if let dogType = dogType{
            setupLabelView(with:dogType)
        }else{
            removeLabelView()
        }
    }
    
    private func setupLabelView(with dogType:String){
        dogLabelContainer.layer.cornerRadius = 5
        dogLabelContainer.layer.zPosition = 999
        dogLabelContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.view.addSubview(dogLabelContainer)
        dogLabelContainer.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        }
        
        self.dogLabelContainer.addSubview(dogTypeLabel)
        dogTypeLabel.textColor = .white
        dogTypeLabel.font = dogTypeLabel.font.withSize(20)
        dogTypeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(dogLabelContainer).inset(7.5)
            make.left.right.equalTo(dogLabelContainer).inset(15)
        }
        dogTypeLabel.text = dogType
        print(dogType)
    }
    
    private func removeLabelView(){
        dogTypeLabel.removeFromSuperview()
        dogLabelContainer.removeFromSuperview()
    }
}


