//
//  CameraView.swift
//  Alarmer Test
//
//  Created by will
//
import SwiftUI
import AVFoundation

struct CameraView: View {
    @State var showImagePicker: Bool = false
    @State var image: UIImage?
    @State var captureSession: AVCaptureSession?
    @State var previewLayer: AVCaptureVideoPreviewLayer?

    var body: some View {
        VStack {
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Scan")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
            
            Button(action: {
                self.showImagePicker = true
            }) {
               Image("CameraIcon")
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: .camera) { image in
                    self.image = image
                    saveImageToDocumentDirectory(image: image)
                       
                }
            }
        }
    }
    
    func saveImageToDocumentDirectory(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let filename = getDocumentsDirectory().appendingPathComponent("image.jpg")
        try? data.write(to: filename)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to do here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var onImagePicked: (UIImage) -> Void
        
        init(onImagePicked: @escaping (UIImage) -> Void) {
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                onImagePicked(image)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

