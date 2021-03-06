//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Mark Gerrior on 5/4/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    // MARK: - Properties

    let context = CIContext(options: nil)

    var originalImage: UIImage? {
        didSet {
            // resize the scaledImage and set it view
            guard let originalImage = originalImage else { return }
            // Height and width
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale  // Size of pixels on this device: 1x, 2x, or 3x
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }

    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }

    // MARK: - Actions

    @IBAction func addButton(_ sender: Any) {
        presentImagePickerControllerToUser()
    }

    // MARK: Slider Actions

    @IBAction func brightnessSlider(_ sender: Any) {
        updateViews()
    }

    @IBAction func contrastAction(_ sender: Any) {
        updateViews()
    }

    @IBAction func saturationAction(_ sender: Any) {
        updateViews()
    }

    @IBAction func blurRadiusAction(_ sender: Any) {
        updateViews()
    }

    @IBAction func blurAngleAction(_ sender: Any) {
        updateViews()
    }

    @IBAction func bumpRadiusAction(_ sender: Any) {
        updateViews()
    }

    @IBAction func bumpScaleAction(_ sender: Any) {
        updateViews()
    }

    // MARK: - Outlets

    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var blurRadiusSlider: UISlider!
    @IBOutlet weak var blurAngleSlider: UISlider!
    @IBOutlet weak var bumpRadiusSlider: UISlider!
    @IBOutlet weak var bumpScaleSlider: UISlider!

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use this to get the details of a given filter.
        // Get CIAttributeSliderMax, CIAttributeSliderMin, & CIAttributeDefault
        let filter = CIFilter(name: "CIBumpDistortion")! // build-in filter from Apple
        print(filter)
        print(filter.attributes)

        // Demo with a starter image from Storyboard
        originalImage = imageView.image
    }

    // MARK: - Private Functions
    private func updateViews() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func presentImagePickerControllerToUser() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    private func filterImage(_ image: UIImage) -> UIImage? {

        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // Filter image step
        let filter = CIFilter(name: "CIColorControls")! // build-in filter from Apple
//        let filter2 = CIFilter.colorControls()
//        filter2.brightness = brightnessSlider.value

        // setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey /* "inputImage" */)
        filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)
        filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)

        guard let stage1 = filter.outputImage else { return nil }

        let blur = CIFilter(name: "CIMotionBlur")!
        blur.setValue(stage1, forKey: kCIInputImageKey /* "inputImage" */)
        blur.setValue(blurRadiusSlider.value, forKey: kCIInputRadiusKey)
        blur.setValue(blurAngleSlider.value, forKey: kCIInputAngleKey)

        guard let stage2 = blur.outputImage else { return nil }

        let bump = CIFilter(name: "CIBumpDistortion")!
        bump.setValue(stage2, forKey: kCIInputImageKey /* "inputImage" */)
        bump.setValue(CIVector(cgPoint: CGPoint(x: 150, y: 150)), forKey: kCIInputCenterKey)
        bump.setValue(bumpRadiusSlider.value, forKey: kCIInputRadiusKey)
        print("bumpScaleSlider.value \(bumpScaleSlider.value)")
        // FIXME: It doesn't seem to like the number I'm passing in here.
//        bump.setValue(0.1, forKey: kCIInputScaleKey)
        bump.setValue(NSNumber(value: bumpScaleSlider.value), forKey: kCIInputScaleKey)

        // CIImage -> CGImage -> UIImage
//        guard let outputCIImage = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return nil }
        guard let outputCIImage = bump.outputImage else { return nil }

        // Render the image (do image processing here)
        guard let outputCGImage = context.createCGImage(outputCIImage,
                                                        from: CGRect(origin: .zero, size: image.size)) else {
                                                            return nil
        }

        return UIImage(cgImage: outputCGImage)
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ImagePostViewController: UINavigationControllerDelegate {
}

