import SwiftUI
import UIKit
import Vision

struct CameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onPhotoTaken: (Bool) -> Void  // ✅ AI Detection Result

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.analyzeImage(image)  // ✅ Run AI Analysis
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.cameraCaptureMode = .photo
        picker.cameraDevice = .front
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // ✅ AI Analysis Function
    func analyzeImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }

        let request = VNDetectHumanRectanglesRequest { request, error in
            if let results = request.results as? [VNHumanObservation], !results.isEmpty {
                DispatchQueue.main.async {
                    self.onPhotoTaken(true)  // ✅ Person detected → Log water intake
                }
            } else {
                DispatchQueue.main.async {
                    self.onPhotoTaken(false)  // ❌ No person detected
                }
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}
