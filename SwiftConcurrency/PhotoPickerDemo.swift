//
//  PhotoPickerDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/10/25.
//

import SwiftUI
import PhotosUI

@MainActor final class PhotoPickerViewModel : ObservableObject{
    @Published private(set) var selectedImage : UIImage? = nil
    @Published var imageSelection : PhotosPickerItem? = nil{
        didSet{
            setImage(from: imageSelection)
        }
    }
    
    
    private func setImage(from selection : PhotosPickerItem?){
        guard let selection else { return }
        Task{
            if let data = try? await selection.loadTransferable(type: Data.self) {
                if let uiimage = UIImage(data: data){
                    selectedImage = uiimage
                    return
                }
            }
        }
    }
}

struct PhotoPickerDemo: View {
    @StateObject private var viewModel = PhotoPickerViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.selectedImage{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200,height: 200)
                    .cornerRadius(10)
            }
            
            PhotosPicker(selection: $viewModel.imageSelection,matching: .images) {
                Text("Open the photo picker!")
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    PhotoPickerDemo()
}
