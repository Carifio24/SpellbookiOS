
//
//  Extensions.swift
//  
//
//  Created by Jonathan Carifio on 12/23/19.
//

import Foundation

extension UIView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}

extension Dictionary {
    subscript<T>(key: T.Type) -> Value? where Key == HashableType<T> {
        get { return self[HashableType(key)] }
        set { self[HashableType(key)] = newValue }
    }
}


extension String {
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            Swift.print(error.localizedDescription)
            return nil
        }
    }
    
    public func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            Swift.print(error)
            return nil
        }
    }
}

extension Sequence {
    
    // A fun little method that calls an instance method on each element of the sequence
    // Basically, the idea is if I have Container<Type>
    // I pass in a method, i.e. Type.instanceMethod
    // and this does element.instanceMethod() for each element in the Sequence
    // Stole this from John Sundell (SwiftBySundell.com)
    func forEach(_ closure: (Element) ->  () -> Void) {
        for element in self {
            closure(element)()
        }
    }
}

// It's annoying to have to convert Strings, etc. to SION before using them as keys
// So we'll just do it once here and be done with it
extension SION {
    
    public subscript(_ key: String) -> SION {
        get {
            return self[SION(key)]
        }
        set {
            self[SION(key)] = newValue
        }
    }
    
}



// For getting the appropriate layout anchor bounds
extension UIView {

    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
  }

    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }

    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
  }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        }
        return self.leadingAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        }
        return self.trailingAnchor
    }
    
}

extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
    }
}


// For getting the default font color below iOS 11
let defaultFontColor: UIColor = {
    if #available(iOS 11.0, *) {
        return UIColor(named: "DefaultFontColor")!
    } else {
        return UIColor.black
    }
}()



extension UIApplication {

    enum ColorMode {
        case dark, light, customColorLowerThanIOS13(_ color: UIColor)
    }

    private func internalSetStatusBarTextColor(_ mode: ColorMode) {
        if #available(iOS 13.0, *) {
            guard let appDelegate = delegate as? AppDelegate else { return }

            var style: UIUserInterfaceStyle

            switch mode {
                case .dark:
                    style = .dark
                default:
                    style = .light
            }

            appDelegate.window?.overrideUserInterfaceStyle = style
        } else {
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                var color: UIColor

                switch mode {
                    case .dark:
                        color = .white
                    case .light:
                        color = .black
                    case .customColorLowerThanIOS13(let customColor):
                        color = customColor
                }

                statusBar.setValue(color, forKey: "foregroundColor")
            }
        }
    }
    
    func setStatusBarTextColor(_ mode: ColorMode) {
        UIView.animate(withDuration: 0.3) {
            self.internalSetStatusBarTextColor(mode)
        }
    }
    
//    func setStatusBarBackgroundColor(_ color: UIColor) {
//
//        var statusBar: UIView?
//        if let viewWithTag = UIApplication.shared.keyWindow?.viewWithTag(999) {
//            statusBar = viewWithTag
//        } else {
//            statusBar = UIView()
//            statusBar!.tag = 999
//            statusBar!.frame = UIApplication.shared.statusBarFrame
//            UIApplication.shared.keyWindow?.addSubview(statusBar!)
//            UIApplication.shared.keyWindow?.sendSubviewToBack(statusBar!)
//        }
//        statusBar!.backgroundColor = color
//    }
    
}

extension UIImage {
    func inverseImage(cgResult: Bool) -> UIImage? {
        let coreImage = UIKit.CIImage(image: self)
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? UIKit.CIImage else { return nil }
        if cgResult { // I've found that UIImage's that are based on CIImages don't work with a lot of calls properly
            return UIImage(cgImage: CIContext(options: nil).createCGImage(result, from: result.extent)!)

        }
        return UIImage(ciImage: result)
    }
}
