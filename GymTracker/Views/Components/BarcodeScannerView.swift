import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewRepresentable {
    @ObservedObject var viewModel: ScannerViewModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        guard let captureSession = viewModel.captureSession else {
            return view
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
} 