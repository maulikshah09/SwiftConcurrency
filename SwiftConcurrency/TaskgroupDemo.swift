//
//  TaskgroupDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 2/27/25.
//

import SwiftUI

class TaskGroupDataManager{
    
    func fetchImageWithAsynclet() async throws -> [UIImage]{
    
    do{
        async let task1 = fetchImage(urlString: "https://picsum.photos/200")
        async let task2 = fetchImage(urlString: "https://picsum.photos/200")
        async let task3 = fetchImage(urlString: "https://picsum.photos/200")
        async let task4 = fetchImage(urlString: "https://picsum.photos/200")
        
        let (task12,task23,task34,task45) = try await (task1,task2,task3,task4)
        
        
        return [task12,task23,task34,task45]
    }catch{
        throw error
    }
}
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage]{
      return  try await withThrowingTaskGroup(of: UIImage.self) { group in
            
          var images: [UIImage] = []
          let myurls = ["https://picsum.photos/200",
                     "https://picsum.photos/200",
                     "https://picsum.photos/200",
                     "https://picsum.photos/200",
                     "https://picsum.photos/200"]
          
          
          for url in myurls{
              group.addTask(priority: .high) {
                  try await self.fetchImage(urlString: url)
              }
          }
         
          
//          group.addTask(priority: .high) {
//              try await self.fetchImage(urlString: "https://picsum.photos/200")
//          }
//
//          group.addTask(priority: .high) {
//              try await self.fetchImage(urlString: "https://picsum.photos/200")
//          }
//
//          group.addTask(priority: .high) {
//              try await self.fetchImage(urlString: "https://picsum.photos/200")
//          }
//
//          group.addTask(priority: .high) {
//              try await self.fetchImage(urlString: "https://picsum.photos/200")
//          }
          
          for try await image in group {
              images.append(image)
          }
          
          return images
        }
    }
    
    
    private func fetchImage(urlString: String) async throws -> UIImage{
        guard let url = URL(string: urlString)  else{
            throw URLError(.badURL)
        }
        do {
            let (data,_)   =  try await  URLSession.shared.data(from: url , delegate: nil)
            
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

class TaskGroupViewModel:ObservableObject{
    let manager =  TaskGroupDataManager()
    @Published  var images : [UIImage] = []

    func getImages() async{
        
        if let images = try? await manager.fetchImagesWithTaskGroup(){
            self.images.append(contentsOf: images)
        }
                                                         
    }
}

struct TaskgroupDemo: View {
    
    @StateObject private var viewModel = TaskGroupViewModel()
   
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    
    let url  = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        
        NavigationStack{
            ScrollView{
                LazyVGrid(columns:columns){
                    ForEach(viewModel.images, id: \.self){ image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            
            .navigationTitle("Task group demoo.")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskgroupDemo()
}
