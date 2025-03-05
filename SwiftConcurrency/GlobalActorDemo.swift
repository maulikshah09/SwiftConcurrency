//
//  GlobalActorDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/5/25.
//

import SwiftUI


//shared instnce are class or struct
@globalActor final class MyFirstGlobalActor{
    static var shared = MyNewDataManager()
}

actor MyNewDataManager{
    
    // it is async func because it is on actor
    func getDataFromDataBase ()  -> [String] {
        return ["One","Two","three","Four","Five"]
    }
}

class GlobalActorViewModel: ObservableObject{
    
    @MainActor @Published var dataArray : [String] = []
    
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor
    func getData() {
        Task{
            let data = await manager.getDataFromDataBase()
          await MainActor.run {
                self.dataArray = data
           }
        }
    }
}

struct GlobalActorDemo: View {
    
    @StateObject private var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.getData()
        }
    }
}

#Preview {
    GlobalActorDemo()
}
