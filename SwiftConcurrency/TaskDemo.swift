//
//  TaskDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 2/26/25.
//

import SwiftUI

class TaskViewModel: ObservableObject{
    
    @Published var image: UIImage? = nil
    
    @Published var image2 : UIImage? = nil
    
    func fetchImage() async {
       try? await Task.sleep(nanoseconds: 5)
        
        do {
            guard let url = URL(string: "https://picsum.photos/200") else{
                return
            }
            
            let (data,_) = try await  URLSession.shared.data(from: url, delegate: nil)
            
            await MainActor.run {
                self.image = UIImage(data: data)
                print("Image returned successfully")
            }
        }
        catch{
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else{
                return
            }
            
            let (data,_) = try await  URLSession.shared.data(from: url, delegate: nil)
            
            self.image2 = UIImage(data: data)
        }
        catch{
            print(error.localizedDescription)
        }
    }
}

struct TaskHomeView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                NavigationLink("Click me") {
                    TaskDemo()
                }
            }
        }
    }
}

struct TaskDemo: View {
  
    @StateObject private var viewModel = TaskViewModel()
    
   // @State private var fetchImageTask : Task<(),Never>? = nil
    
    var body: some View {
        VStack{
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        
        .task {
            await viewModel.fetchImage()
        }
        
        .onAppear{
//            Task{ // it run synchronize
//                await viewModel.fetchImage()
//                await viewModel.fetchImage2()
//            }
            
            
            // if you want on same time
//            fetchImageTask = Task{ // no need  to create your own task if .task you write.
//              //  print(Thread.current)
//              //  print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
//            
//            Task{
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
            
            
            
//            Task(priority: .low) {
//                print("Low")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print("End")
//            }
//            
//            Task(priority: .medium) {
//                print("medium")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print("End")
//            }
//            
//            Task(priority: .high) {
//                print("high")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print("End")
//            }
//            
//            
//            Task(priority: .background) {
//                print("background")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print("End")
//            }
//            
//            Task(priority: .utility) {
//                print("utility")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print("End")
//            }
//
            
            
//            Task(priority: .low) {
////                print("userInitiated")
//                print(Task.currentPriority)
////                print("End")
//
//                Task.detached(priority: .utility){
//                    print("Detached",Task.currentPriority)
//                }
//            }
            
            
            
        }
        
//        .onDisappear {
//            fetchImageTask?.cancel()
//            print("cancelled")
//        }
    }
}

#Preview {
    TaskDemo()
}
