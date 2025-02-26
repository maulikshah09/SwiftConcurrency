//
//  DoTryCatchThrowDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 2/16/25.
//

import SwiftUI

class DoCatchTryThrowsDataManager{
    let active = true
    
    func getTitle() throws -> String{
        if active{
            return "new text!"
        }
        throw URLError(.networkConnectionLost)
    }
    
    func getTitle2() throws -> String{
//        if active{
//            return "Final text"
//        } 
        throw URLError(.networkConnectionLost)
    }
}

class DoCatchTryThrowViewModel : ObservableObject{
    @Published var text = "Hello, World!"
    let manager = DoCatchTryThrowsDataManager()
     
    func fetchTitle (){
        do {
            let newtitle = try manager.getTitle()
            self.text = newtitle
            
            let finaltext = try manager.getTitle2()
            self.text = finaltext
        }catch let error{
            self.text = error.localizedDescription
        }
    }
}


struct DoTryCatchThrowDemo: View {
    
    @StateObject private var viewModel = DoCatchTryThrowViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300,height: 300)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoTryCatchThrowDemo()
}
