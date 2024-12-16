import AVFoundation
import SwiftUI

class ScannerViewModel: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var scannedProduct: ScannedProduct?
    @Published var errorMessage: String?
    
    var captureSession: AVCaptureSession?
    private let foodDatabaseService = FoodDatabaseService()
    
    func startScanning() {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            requestCameraPermission()
            return
        }
        
        setupCaptureSession()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupCaptureSession()
                } else {
                    self?.errorMessage = "Kamera-Zugriff wird benötigt"
                }
            }
        }
    }
    
    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            errorMessage = "Kamera konnte nicht initialisiert werden"
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddInput(videoInput) &&
           captureSession.canAddOutput(metadataOutput) {
            
            captureSession.addInput(videoInput)
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13]
            
            self.captureSession = captureSession
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isScanning = true
                }
            }
        }
    }
    
    private func fetchProductData(barcode: String) {
        Task {
            do {
                let product = try await foodDatabaseService.fetchProduct(barcode: barcode)
                DispatchQueue.main.async {
                    self.scannedProduct = product
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Produkt konnte nicht gefunden werden"
                }
            }
        }
    }
}

extension ScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let barcode = readableObject.stringValue else { return }
        
        captureSession?.stopRunning()
        isScanning = false
        
        // Fetch product data from the German food database
        fetchProductData(barcode: barcode)
    }
} 