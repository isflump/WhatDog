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
    var dogTypeLabel:UILabel?
    var dogLabelContainer: UIView?

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
        setupLabelView()
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
            dogTypeLabel?.text = dogType
            dogLabelContainer?.isHidden = false
        }else{
            dogLabelContainer?.isHidden = true
        }
    }
    
    private func setupLabelView(){
        dogLabelContainer = UIView()
        dogLabelContainer?.layer.cornerRadius = 5
        dogLabelContainer?.layer.zPosition = 999
        dogLabelContainer?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        guard let dogLabelContainer = dogLabelContainer else {return}
        self.view.addSubview(dogLabelContainer)
        dogLabelContainer.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        }
        dogTypeLabel = UILabel()
        dogTypeLabel?.textColor = .white
        dogTypeLabel?.font = dogTypeLabel?.font.withSize(20)
        guard let dogTypeLabel = dogTypeLabel else {return}
        self.dogLabelContainer?.addSubview(dogTypeLabel)
        dogTypeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(dogLabelContainer).inset(7.5)
            make.left.right.equalTo(dogLabelContainer).inset(15)
        }
    }
}


