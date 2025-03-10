//
//  AsyncPublisher.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/9/25.
//

import SwiftUI

class AsyncPublisherDataManager {
    
    @Published var myData : [String] = []
    
    func addData () async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banna")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
    
}


class AsyncPublisherViewModel : ObservableObject{
    
    @MainActor @Published var dataArray : [String] = []
    
    let manager = AsyncPublisherDataManager()
    
    init(){
        addSubscribers()
    }
    
    private func addSubscribers(){
        
        Task{
            for await value in  manager.$myData.values {
                await MainActor.run {
                    self.dataArray = value
                }
            }
        }
       
    }
    
    func start() async {
        await manager.addData()
    }
    
}


struct AsyncPublisherDemo: View {
    
    @StateObject private var viewmodel = AsyncPublisherViewModel()
    
    var body: some View {
        
        ScrollView{
            VStack{
                ForEach (viewmodel.dataArray, id: \.self){
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewmodel.start()
        }
    }
}

#Preview {
    AsyncPublisherDemo()
}
