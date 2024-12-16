import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var scannerViewModel = ScannerViewModel()
    @State private var showingScanner = false
    
    var body: some View {
        NavigationView {
            VStack {
                if scannerViewModel.isScanning {
                    BarcodeScannerView(viewModel: scannerViewModel)
                        .frame(height: 400)
                } else {
                    Button(action: {
                        showingScanner = true
                    }) {
                        VStack {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 60))
                            Text("Barcode scannen")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                if let scannedProduct = scannerViewModel.scannedProduct {
                    ProductDetailView(product: scannedProduct)
                }
            }
            .padding()
            .navigationTitle("Scanner")
        }
    }
} 