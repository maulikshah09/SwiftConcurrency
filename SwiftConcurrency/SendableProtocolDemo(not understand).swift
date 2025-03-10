//
//  SendableProtocolDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/6/25.
//

import SwiftUI

actor CurrentUserManager{
    
    func updateDataBase(userinfo : MYClassUserInfo){
        
    }
    
}

struct MyUserInfo: Sendable {
    var name : String
}

final class MYClassUserInfo : Sendable{
    var name : String
    
    init(name: String) {
        self.name = name
    }
}

class SendableViewModel : ObservableObject{
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo()  async {
        let info = MYClassUserInfo(name: "maulik")
        
        await manager.updateDataBase(userinfo: info)
    }
}

struct SendableProtocolDemo: View {
    
    @StateObject private var viewModel = SendableViewModel()
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    SendableProtocolDemo()
}
