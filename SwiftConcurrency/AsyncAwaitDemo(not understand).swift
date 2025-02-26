//
//  AsyncAwaitDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 2/26/25.
//

import Foundation
import SwiftUI

class AsyncAwaitViewModel: ObservableObject{
    @Published var dataArray:[String] = []
    
//    func addTitle1() {
//        DispatchQueue.main.asyncAfter(deadline:.now() + 2){
//            DispatchQueue.main.async{
//                self.dataArray.append("Title 1:\(Thread.current)")
//             }
//        }
//    }
//
    
    
//    func addTitle2() {
//        DispatchQueue.global().asyncAfter(deadline:.now() + 2){
//            //bakckground thread
//            let title = "Title 2:\(Thread.current)"
//
//            DispatchQueue.main.async{
//              //  main
//                self.dataArray.append(title)
//                
//                let title3 = "Title 3:\(Thread.current)"
//                self.dataArray.append(title3)
//            }
//        }
//    }
    
    
    func addAuther1() async{
        let author1 = "Author1 : \(Task.currentPriority)"
        self.dataArray.append(author1)
        
        try? await Task.sleep(for: .seconds(2_000_000_000))
      
        let author2 = "Author2 : \(Task.currentPriority)"
        
        await MainActor.run {
            self.dataArray.append(author2)
            
            let Author3 = "Author3 : \(Task.currentPriority)"
             self.dataArray.append(Author3)
        }
    }
    
    func addSomthing () async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        let somthing1 = "Somthing1 : \(Task.currentPriority)"
        
        await MainActor.run {
            self.dataArray.append(somthing1)
            
            let somthing2 = "somthing2 : \(Task.currentPriority)"
             self.dataArray.append(somthing2)
        }
    }
}

struct AsyncAwaitDemo: View {
    @StateObject private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        
        List{
            ForEach(viewModel.dataArray, id: \.self){ data in
                Text(data)
            }
        }
        .onAppear{
            Task {
               await viewModel.addAuther1()
                
                await viewModel.addSomthing()
                
                let isMainThread = Thread.isMainThread ? "Main Thread" : "Background Thread"
                let finalText = "Final text : \(isMainThread)"
                
        
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

#Preview {
    AsyncAwaitDemo()
}
