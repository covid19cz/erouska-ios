//
//  Image.swift
//  BT-Tracking
//
//  Created by Lukáš Foldýna on 26/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit

extension UIImage {

    func resize(toWidth width: CGFloat) -> UIImage? {
         let scale = width / size.width
         let newHeight = size.height * scale

         UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: newHeight), false, UIScreen.main.scale)
         draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))

         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()

         return newImage
     }

}
