//
//  VideoClientCustomRect.swift
//  VideoClient
//
//  Created by kpicart on 6/18/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit

//create main textFields
var isDeviceVertical = true

class VideoClientCustomRect: UIViewController  {
    
    //var for holding frame sizes
    internal var activeFrameSize = CGSize()
    private var positionID = String()
//MARK: - custom textField settings
    
       
    //set and return divisors based on string ID
    private func framePositionCal() ->(positionValue:CGPoint,sizeValue:CGSize) {
        
        var cgPointDivisor = CGPoint()
        var cgSizeDivisor = CGSize()
        
        switch positionID {
        case "topTextField":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: -375.0, y: 7.0) : CGPoint(x: -667.0, y: 7.0)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.0, height: 15.0) :  CGSize(width: 1.0, height: 8.9)
        
        case "videoPlaybackView":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: -375.0, y: 7.3) : CGPoint(x: -667.0, y: 7.2)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.0, height: 1.45) : CGSize(width: 1.0, height: 1.4)
            
        case "bottomTextField":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: -375.0, y: 1.29) : CGPoint(x: -667.0, y: 1.3)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.0, height: 15.0) :  CGSize(width: 1.0, height: 8.9)
            
        case "sourceImageView":
            cgPointDivisor = isDeviceVertical == true ? CGPoint(x: 5.0, y: 9.0) : CGPoint(x: 3.9, y: 22.0)
            cgSizeDivisor = isDeviceVertical == true ? CGSize(width: 1.5, height: 2.0) :  CGSize(width: 2.0, height: 1.4)

        default:
            print("out of options")
        }
        return  (cgPointDivisor,cgSizeDivisor)
    }
    
    //get current display frame with string ID from global var, set by calling func
    internal func getCGRectPosition(_ ID:String) ->(CGRect){
    positionID = ID
        let videoCGRect = CGRect(x: (activeFrameSize.width / framePositionCal().positionValue.x),
                                 y: (activeFrameSize.height / framePositionCal().positionValue.y),
                                 width: activeFrameSize.width / framePositionCal().sizeValue.width,
                                 height: activeFrameSize.height / framePositionCal().sizeValue.height)
        return (videoCGRect)
    }
    
    
    //MARK -set text and text field attributes
    
   private let videoTextAttrib:[ String : Any] =
        [NSStrokeColorAttributeName: (UIColor .black),
         NSForegroundColorAttributeName: (UIColor .white),
         NSStrokeWidthAttributeName:(size: -1.0),
         NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)! ]
    
    internal func textFieldSettings(placeHolderText: String) ->UITextField {
       
        let textField = UITextField()
        
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText.uppercased(), attributes:[NSFontAttributeName: UIColor.white])
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.bottom
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        
        textField.backgroundColor = UIColor.clear
        textField.defaultTextAttributes = videoTextAttrib
        
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        
        return textField
    }
}
