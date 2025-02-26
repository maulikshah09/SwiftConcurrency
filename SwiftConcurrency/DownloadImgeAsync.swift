//
//  DownloadImgeAsync.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 2/26/25.
//

import SwiftUI
import Combine

class DownloadImgeAsyncImageLoader {
   
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data : Data?, response : URLResponse?) -> UIImage?{
        guard let data = data,let image = UIImage(data: data),let response = response as? HTTPURLResponse,
       
        response.statusCode >= 200 && response.statusCode < 300
        else {
            return nil
        }
        
        return image
    }
    
    func downloadImage(completion: @escaping (_ image:UIImage?, _ error : Error?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
          
            let image = self?.handleResponse(data: data, response: response)
           
            completion(image,error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?,Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage?{
        
        do{
            let (data,response) = try await URLSession.shared.data(from: url, delegate: nil)
            
            return handleResponse(data: data, response: response)

        }
        catch{
            throw error
        }
       
        
        
    }
}

class DownloadImgeAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImgeAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
   
    func FetchImage() {
        loader.downloadImage { [weak self] image, error in
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func fetchWithCombine(){
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: {[weak self] image in
                    self?.image = image
            }
            .store(in: &cancellables)
    }
    
 
    func fetchWithAsync() async {
        
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}
 

struct DownloadImgeAsync: View {
    @StateObject private var viewModel = DownloadImgeAsyncViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250,height: 250)
            }
        }
        .onAppear{
            Task{
                await viewModel.fetchWithAsync()
            }
        }

    }
}

#Preview {
    DownloadImgeAsync()
}
