//
//  ReferenceBootCamp.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/9/25.
//

import SwiftUI

final class ReferenceDataService {
    
    func getData() async -> String {
        return "Update data"
    }
}

final class ReferenceViewModel : ObservableObject{
    @Published var data : String = "Some title"

    let dataService =  ReferenceDataService()
    
    // this implies a strong references
    func updateData () {
        Task {
            data = await self.dataService.getData()
        }
    }
    
    // this implies a strong references
    func updateData2() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // this implies a strong references
    func updateData3() {
        Task { [self] in
            self.data = await  self.dataService.getData()
        }
    }
    
    // this is weak references
    func updateData4() {
        Task { [weak self] in
            if let data =  await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    // this implies a strong references
    func updateData5() {
        Task { [self] in
            self.data = await  self.dataService.getData()
        }
    }
    
    // this implies a strong references
    func updateData6() {
        Task { [self] in
            self.data = await  self.dataService.getData()
        }
    }
}

struct ReferenceBootCamp: View {
    
    @StateObject private var viewModel = ReferenceViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear{
                viewModel.updateData()
            }
    }
}

#Preview {
    ReferenceBootCamp()
}
