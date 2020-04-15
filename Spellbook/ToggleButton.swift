//
//  ToggleButton.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/7/19.
//  Copyright © 2019 Jonathan Carifio. All rights reserved.
//

import UIKit

class ToggleButton: UIButton {

    // Member values
    private var imageT: UIImage
    private var imageF: UIImage
    private var on: Bool
    private var callback: () -> Void
    private var longPressCallback: () -> Void = { return }
    
    // Constructors
    init(_ imageF: UIImage, _ imageT: UIImage, _ on: Bool = false, _ callback: @escaping () -> Void = { () in () }) {
        self.imageF = imageF
        self.imageT = imageT
        self.on = on
        self.callback = callback
        super.init(frame: .zero)
        initialSetup()
    }
    
    convenience init(_ fnameF: String, _ fnameT: String, _ on: Bool = false, _ callback: @escaping () -> Void = { () in () }) {
        let imgF = UIImage(named: fnameF)?.withRenderingMode(.alwaysOriginal)
        let imgT = UIImage(named: fnameT)?.withRenderingMode(.alwaysOriginal)
        self.init(imgT ?? UIImage(), imgF ?? UIImage(), on, callback)
    }
    
    convenience init() {
        self.init(UIImage(), UIImage(), false, { () in () })
    }
    
    required init?(coder decoder: NSCoder) {
        self.on = false
        self.imageT = UIImage()
        self.imageF = UIImage()
        self.callback = { () in () }
        super.init(coder: decoder)
        initialSetup()
    }
    
    ///// Methods
    
    // What to do when the button is pressed
    @objc private func onClicked(sender: ToggleButton) {
        toggle()
        callback()
    }
    
    // For initial setup purposes
    private func initialSetup() {
        
        // Set the button to the correct status
        set(on)
        
        // Set what happens when the button is pressed
        self.addTarget(self, action: #selector(onClicked(sender:)), for: .touchUpInside)
        
        // Set what happens when the button is long pressed
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed(_:)))
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    // Set the button to the desired state
    func set(_ b: Bool) {
        on = b
        updateImage()
    }
    
    private func updateImage() {
        let toSet: UIImage = on ? imageT : imageF
        setImage(toSet, for: .normal)
    }
    
    // Toggle the button
    private func toggle() {
        on = !on
        set(on)
    }
    
    // Set the callback for the button
    func setCallback(_ cb: @escaping () -> Void) {
        callback = cb
    }
    
    func getCallback() -> () -> Void { return callback }
    
    // Set the long press callback for the button
    func setLongPressCallback(_ cb: @escaping () -> Void) {
        longPressCallback = cb
    }
    
    // Get the button's state
    func isSet() -> Bool { return on }
    
    func offImageHeight() -> CGFloat { return imageF.size.height }
    func onImageHeight() -> CGFloat { return imageT.size.height }
    func offImageWidth() -> CGFloat { return imageF.size.width }
    func onImageWidth() -> CGFloat { return imageT.size.width }
    func setTrueImage(image: UIImage) {
        imageT = image
        if (on) { updateImage() }
    }
    func setFalseImage(image: UIImage) {
        imageF = image
        if (!on) { updateImage() }
    }
    
    // What to do when long pressed
    @objc func onLongPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            longPressCallback()
        }
    }
    
//    // Set the image height and width
//    func setImageSize(size: CGSize) {
//        let renderer = UIGraphicsImageRenderer(size: size)
//        let newImageT = renderer.image { _ in
//            imageT.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
//        }
//        let newImageF = renderer.image { _ in
//            imageF.draw(in: CGRect.init(origin: CGPoint.zero, size: size))
//        }
//        imageT = newImageT
//        imageF = newImageF
//        set(on)
//    }
//    
//    func setImageSize(width: Int, height: Int) {
//        setImageSize(CGSize(width: width, height: height))
//    }
    
    
}
