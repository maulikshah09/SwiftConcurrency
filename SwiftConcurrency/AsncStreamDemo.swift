//
//  AsncStreamDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/11/25.
//

import SwiftUI

class AsyncStreamDataManager{
    
//    func getAsyncStream() -> AsyncStream<Int>{
//        AsyncStream { [weak self] continuation in
//            
//            self?.getFakeData(newValue: { value in
//                continuation.yield(value)
//            }, onFinish: { error in
//                if let error{
//                    continuation.onTermination
//                }
//                continuation.finish()
//            })
//        }
//    }
    
    func getAsyncStream() -> AsyncThrowingStream<Int, Error>{
        AsyncThrowingStream { [weak self] continuation in
            
            self?.getFakeData(newValue: { value in
                continuation.yield(value)
            }, onFinish: { error in
                if let error{
                    continuation.finish(throwing: error)
                }else{
                    continuation.finish()
                }
            })
        }
    }
    
    func getFakeData(newValue : @escaping (_ value : Int) -> (),
                     onFinish : @escaping(_ error : Error?) -> Void
    )   {
        let items: [Int] = [1,2,3,4,5,6,7,8,9,10]
        
        for item in items{
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)){
                newValue(item)
                
                if item == items.last{
                    onFinish(nil)
                }
            }
        }
    }
}

@MainActor
final class AsyncStreamViewModel : ObservableObject{
    
    let manager = AsyncStreamDataManager()
    @Published private(set) var currentNumber : Int = 0
    
    func onViewAppear(){
       let task = Task{
            do{
                for try await value in manager.getAsyncStream(){
                    currentNumber = value
                }
            }
            catch{
                print(error)
            }
           
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            task.cancel()
            print("Task cancelled")
        }
    }
}

struct AsncStreamDemo: View {
    @StateObject private var viewModel  = AsyncStreamViewModel()
    
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    AsncStreamDemo()
}
