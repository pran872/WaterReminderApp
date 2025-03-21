import SwiftUI
import UIKit
import Vision

struct CameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var showErrorAlert: Bool  // Added binding for showErrorAlert
    var onPhotoTaken: (Bool) -> Void  // AI Detection Result

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.analyzeImage(image)  // Run AI Analysis
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

    // AI Analysis Function
    func analyzeImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }

        // Corrected hand pose detection
        let handPoseRequest = VNDetectHumanHandPoseRequest { request, error in
            if let error = error {
                print("[DEBUG] Error detecting hand pose: \(error.localizedDescription)")
                return
            }

            if let handResults = request.results as? [VNHumanHandPoseObservation], !handResults.isEmpty {
                if let hand = handResults.first {
                    // Check proximity of hand to the nose
                    self.checkHandProximityToNose(hand)
                }
            }
        }

        // Perform the hand pose request with error handling
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([handPoseRequest])
        } catch {
            print("[DEBUG] Failed to perform hand pose request: \(error.localizedDescription)")
        }
    }

    func checkHandProximityToNose(_ hand: VNHumanHandPoseObservation) {
        // Get hand joint positions
        if let thumbTip = try? hand.recognizedPoint(.thumbTip), let indexTip = try? hand.recognizedPoint(.indexTip) {
            // Assuming nose position is available, use nose position from Vision's face detection
            let nosePosition = CGPoint(x: 0.5, y: 0.5) // Placeholder for nose position

            // Calculate distances from hand to nose for both thumb and index tips
            let thumbDistance = calculateDistance(from: nosePosition, to: thumbTip.location)
            let indexDistance = calculateDistance(from: nosePosition, to: indexTip.location)

            // Debugging: print the distances
            print("[DEBUG] Distance between thumb and nose: \(thumbDistance)")
            print("[DEBUG] Distance between index and nose: \(indexDistance)")

            // Set proximity threshold and check if the hand is near the nose
            let threshold: CGFloat = 50.0 // Adjust based on testing
            if thumbDistance < threshold || indexDistance < threshold {
                print("[DEBUG] Hand is close to the nose. Likely drinking.")
                self.onPhotoTaken(true)  // Drinking detected
            } else {
                print("[DEBUG] Hand is not close to the nose. Not drinking.")
                self.onPhotoTaken(false)  // Not drinking
                self.showErrorAlert = true // Trigger the alert
            }
        }
    }


    // Function to calculate distance between two points (CGPoint)
    func calculateDistance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
}
