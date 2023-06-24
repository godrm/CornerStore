//
//  CameraViewController.swift
//  CornerStore
//
//  Created by JK on 2023/04/20.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var itemResult: UILabel!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var guideLabel: UILabel!
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let imagePredictor = ImagePredictor()

    override func viewDidLoad() {
        super.viewDidLoad()
        
#if targetEnvironment(simulator)
        guideLabel.isHidden = false
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapPreview))
        preview.addGestureRecognizer(recognizer)
#else
        guideLabel.isHidden = true
        initSession()
        addPreview()
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
#endif
    }
            
    func initSession() {
        captureSession.beginConfiguration()

        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
                captureSession.canAddInput(videoDeviceInput)
            else { return }
        captureSession.addInput(videoDeviceInput)

        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)

        captureSession.commitConfiguration()
    }

    func addPreview() {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let rootLayer = preview.layer
        previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(previewLayer)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto
                        photo: AVCapturePhoto, error: Error?) {
        if let dataImage = photo.fileDataRepresentation() {
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage = CGImage(jpegDataProviderSource: dataProvider!,
                            decode: nil, shouldInterpolate: true, intent: .defaultIntent)!
            let image = UIImage.init(cgImage: cgImageRef)
            self.classifyImage(image)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "recommend" else { return }
        //다음화면 넘어가기
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                  kCVPixelBufferWidthKey as String: 1024,
                                  kCVPixelBufferHeightKey as String: 1024]
        settings.previewPhotoFormat = previewFormat
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    @objc private func tapPreview(rec: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: true)
    }
}

extension CameraViewController: UINavigationControllerDelegate & UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.classifyImage(image)
    }

    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }

    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            print("No predictions. (Check console log.)")
            return
        }

        let formattedPredictions = formatPredictions(predictions)
        let predictionString = formattedPredictions.joined(separator: "\n")
        print(predictionString)
    }

    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        let predictionsToShow = 2
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            var name = prediction.classification
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }
            return "\(name) - \(prediction.confidencePercentage)%"
        }
        return topPredictions
    }
}

