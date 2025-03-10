//
//  RefereshableDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/9/25.
//

import SwiftUI

final class RefereshableDataService{
    func getData() async throws  -> [String]{
        try? await Task.sleep(nanoseconds: 5_000_000_000)
      return  ["Apple","Orange","Banana"].shuffled()
    }
}


@MainActor
final class RefereshableViewModel : ObservableObject{
    
    @Published private(set) var items : [String] = []
    
    let manager = RefereshableDataService()
    
    func loadData() async {
        
        do {
            items = try await manager.getData()
        }
        catch{
            print(error)
        }
    }
    
}

struct RefereshableDemo: View {
    
    @StateObject private var viewModel =  RefereshableViewModel()
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    ForEach(viewModel.items, id: \.self){ items in
                        Text(items)
                            .font(.headline)
                    }
                }
            }
            .refreshable {
               await viewModel.loadData()
            }
            .task{
                await viewModel.loadData()
            }
            
            .navigationTitle("Refreshable")
        }
       
    }
}

#Preview {
    RefereshableDemo()
}
