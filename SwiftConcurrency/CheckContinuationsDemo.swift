//
//  ContinuationsDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/5/25.
//

import SwiftUI

class CheckContinuationsNetworkManager {
    
    func getData(url : URL) async throws -> Data{
        do {
            let (data,_) = try await URLSession.shared.data(from: url,delegate : nil)
            
            return data
        }catch{
            throw error
        }
    }
    
    func getData2(url : URL) async throws -> Data{
        
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let data = data{
                    continuation.resume(returning: data)
                }else if let error = error{
                    continuation.resume(throwing: error)
                }else{
                    continuation.resume(throwing: URLError(.badURL) )
                }
            }
            .resume()
         }
     }
}

//comverted into async await. non async to async
class CheckContinuationsViewModel : ObservableObject{
    @Published var image : UIImage? = nil
    let networkManager = CheckContinuationsNetworkManager()
    
    func getImage() async{
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data) {
                
                await MainActor.run {
                    self.image = image
                }
            }
        }
        catch{
            print(error)
        }
    }

}

struct CheckContinuationsDemo: View {
    @StateObject var viewModel = CheckContinuationsViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200,height: 200)
            }
        }
        .task {
            await viewModel.getImage()
        }
        
    }
}

#Preview {
    CheckContinuationsDemo()
}
