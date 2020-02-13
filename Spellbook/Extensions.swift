
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
            print(error.localizedDescription)
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
            print(error)
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
