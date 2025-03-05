//
//  StructClassActorDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/5/25.
//

import SwiftUI

struct StructClassActorDemo: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear{
                runTest()
            }
    }
}

#Preview {
    StructClassActorDemo()
}
 


extension StructClassActorDemo{
    private func runTest() {
        print("Test Started")
        structTest1()
        printDivider()
        classTest1()
        printDivider()
        
        Task{
            await actorTest1()
        }
      
        
//        structTest2()
//        printDivider()
//        classTest2()
    }
    
    private func printDivider() {
        print("""
        
        - - - - - - - - - - - - - - - - - - - -  
        
        """)
    }
    
    private func structTest1() {
        print("Struct Test")
        let obj = MyStruct(title: "Starting title")
        print("Obj A", obj.title)
        
        var obj2 = obj
        print("Obj B", obj2.title)
        
        obj2.title = "Second title"
        print("Obj B title change")
        
        print("Obj A", obj.title)
        print("Obj B", obj2.title)
    }
    
    private func classTest1 () {
        print("Class Test")
        let objA =   MYClass(title: "Starting title")
        print("Obj A", objA.title)
        
        let objB = objA
        print("Obj B", objB.title)
        
        objB.title = "Second title"
        print("Obj B title change")
        
        print("Obj A", objA.title)
        print("Obj B", objB.title)
    }
    
    
    private func actorTest1 () async {
        Task{
            print("Actor Test")
            let objA =   MYActor(title: "Starting title")
            await print("Obj A", objA.title)
            
            let objB = objA
            await print("Obj B", objB.title)
            
            await objB.updateTitle(newTitle: "Second title")
        //    objB.title = "Second title"
            print("Obj B title change")
            
            await print("Obj A", objA.title)
            await print("Obj B", objB.title)
        }
    }
}

struct MyStruct{
    var title : String
}

//immutable struct
struct CustomStruct{
    let title : String
    
    func updateTitle(newTitle : String) -> CustomStruct{
        CustomStruct(title: newTitle)
    }
}

struct MutatingStruct{
    private(set) var title : String
    
    init(title: String) {
        self.title = title
    }
    
    
    mutating func updateTitle(newTitle : String){
        title =  newTitle
    }
}

extension StructClassActorDemo {
  
    private func structTest2(){
        print("struct 2")
        
        var struct1 =  MyStruct(title: "title 1")
        print("struct1 : ",struct1.title)
        struct1.title = "Title2"
        print("struct1:", struct1.title)
        
        var struct2 = CustomStruct(title: "title 1")
        print("Struct 2",struct2.title)
        
        struct2 = CustomStruct(title: "Title 2")
        print("Struct 2",struct2.title)
        
        var struct3 = CustomStruct(title: "title 1")
        print("Struct 3",struct3.title)
        struct3 = struct3.updateTitle(newTitle: "title 2")
        print("Struct 3",struct3.title)
        
        var struct4 = MutatingStruct(title: "title 1")
        print("Struct 4",struct4.title)
        struct4.updateTitle(newTitle: "title 2")
        print("Struct 4",struct3.title)
        
    }
}


class MYClass{
    var title : String
    
    init(title : String) {
        self.title = title
    }
    
    func updateTitle(newTitle : String) {
        self.title = newTitle
    }
}


actor MYActor{
    var title : String
    
    init(title : String) {
        self.title = title
    }
    
    func updateTitle(newTitle : String) {
        self.title = newTitle
    }
}

extension StructClassActorDemo{
    private func classTest2(){
        print("Class test2  ")
        
        let class1 = MYClass(title: "title1")
        print("class1 : ", class1.title)
        class1.title = "title2"
        print("class1 : ", class1.title)
        
        
        let class2 = MYClass(title: "title1")
        print("class2 : ", class2.title)
        class2.updateTitle(newTitle: "title2")
        print("class2 : ", class2.title)
        
    }
}
