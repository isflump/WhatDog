//
//  MobileNet+Fritz.swift
//  WhatDog
//
//  Created by Eric Hsiao on 2/5/18.
//  Copyright © 2018 Jiaqi Yan. All rights reserved.
//

import Fritz

extension MobileNet: SwiftIdentifiedModel {

    static let modelIdentifier = "<insert model id>"

    static let packagedModelVersion = 1

    static let session = Session(appToken: "<insert app token>")
}
