//
//  AsyncLet.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 2/26/25.
//

import SwiftUI

struct AsyncLetDemo: View {
    
    @State private var image : [UIImage] = []
    
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    let url  = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        
        NavigationStack{
            ScrollView{
                LazyVGrid(columns:columns){
                    ForEach(image, id: \.self){ image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            
            .navigationTitle("Async Let demoo.")
            .onAppear {
                //                Task{
                //                    do {
                //                      let image1 =  try await fetchImage()
                //
                //                        self.image.append(image1)
                //
                //                        let image2 =  try await fetchImage()
                //
                //                          self.image.append(image2)
                //                        let image3 =  try await fetchImage()
                //
                //                          self.image.append(image3)
                //                        let image4 =  try await fetchImage()
                //
                //                          self.image.append(image4)
                //
                //                        let image5 =  try await fetchImage()
                //
                //                          self.image.append(image5)
                //                    }
                //                    catch{
                //                        print(error)
                //                    }
                //                }
                
                
                Task{
                    do {
                        
                        async let featchImage1 = fetchImage()
                        
                        async let featchImage2 = fetchImage()
                        
                        async let featchImage3 = fetchImage()
                        
                        async let featchImage4 = fetchImage()
                        
                        let (image1,image2, image3,image4) = try await (featchImage1,featchImage2, featchImage3,featchImage4)
                        
                        self.image .append(contentsOf: [image1,image2, image3,image4])
                        
                        
                    }
                    catch{
                        print(error)
                    }
                }
             
            }
        }
    }
    
    func fetchImage() async throws -> UIImage{
        
        do {
            let (data,response)   =     try await  URLSession.shared.data(from: url , delegate: nil)
            
            if let image = UIImage(data: data){
                return image
            }else{
                throw URLError(.badURL)
            }
            
        } catch  {
            throw error
        }
    }
}

#Preview {
    AsyncLetDemo()
}
