//
//  ActorDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/5/25.
//

import SwiftUI

// 1. what is the problem that actor are solving
// 2. how was this problem solved prior to actors?
// 3. actor can solve the problem!


class MYDataManager{
    static let instance = MYDataManager()
    
    private init() {}
    
    var data : [String] = []
    private let queue : DispatchQueue = .init(label: "com.example.myqueue")
    
    
    func getRandomData(commplitionHandler: @escaping (_ title : String?) -> Void) {
        queue.async {
            self.data.append(UUID().uuidString)
            
            print(Thread.current)
            commplitionHandler(self.data.randomElement())
        }
    }
}

actor MyActorDataManager{
    static let instance = MyActorDataManager()
    
    private init() {}
    
    var data : [String] = []
    private let queue : DispatchQueue = .init(label: "com.example.myqueue")
    
    var text : String? // non isolate
    
    
    // this is isolate method  it must be use async
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        
    print(Thread.current)
       return self.data.randomElement()
    }
    
    // this is not isolated method it not used async
    nonisolated func readData () -> String {
        return "Maulik"
    }
}


struct HomeView : View {
    
    let manager = MyActorDataManager.instance
    
    @State private var text : String = ""
    let timer =  Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ZStack{
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let title {
//                        DispatchQueue.main.async{
//                            self.text = title
//                        }
//                    }
//                }
//            }
            
            Task{
                if  let data = await manager.getRandomData(){
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            
        }
    }
}

struct BrowserView : View {
    
    let manager = MyActorDataManager.instance

    @State private var text : String = ""
    let timer =  Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
   
    var body: some View {
        
        ZStack{
            Color.yellow.opacity(0.8).ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let title {
//                        DispatchQueue.main.async{
//                            self.text = title
//                        }
//                    }
//                }
//            }
            
            Task{
                if  let data = await manager.getRandomData(){
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        }
    }
}

struct ActorDemo: View {
    var body: some View {
        TabView{
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowserView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorDemo()
}
