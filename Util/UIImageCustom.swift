//
//  UIImageCustom.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/13.
//

import UIKit

extension UIImage {
    class func create(
        symbol: String,
        color: UIColor? = nil,
        pointSize: CGFloat? = nil,
        weight: UIImage.SymbolWeight? = nil
    ) -> UIImage {
        let image: UIImage
        if let pointSize = pointSize, let weight = weight {
            image = UIImage(
                systemName: symbol,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
            )!
        } else if let pointSize = pointSize {
            image = UIImage(
                systemName: symbol,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: pointSize)
            )!
        } else if let weight = weight {
            image = UIImage(
                systemName: symbol,
                withConfiguration: UIImage.SymbolConfiguration(weight: weight)
            )!
        } else {
            image = UIImage(systemName: symbol)!
        }

        if let color = color {
            return image.withTintColor(color, renderingMode: .alwaysOriginal)
        } else {
            return image
        }
    }
}
