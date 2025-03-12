//
//  ObservableDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/11/25.
//

import SwiftUI

actor TitleDatabase {
    func getNewTitle() -> String{
        "Some new title "
    }
}

@Observable
class ObservableViewModel  {
   
    @ObservationIgnored let database = TitleDatabase()
    @MainActor var title = "string title"
   
    @MainActor
    func updateTitle() async {
        title = await database.getNewTitle()
        print(Thread.current)
    }
}



struct ObservableDemo: View {
    @State private var viewModel = ObservableViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .task {
                await viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableDemo()
}
