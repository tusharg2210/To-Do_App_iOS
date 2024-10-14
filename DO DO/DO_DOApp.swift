//
//  DO_DOApp.swift
//  DO DO
//
//  Created by Tushar Gupta on 07/10/24.
//

import SwiftUI
import Firebase



@main
struct DO_DOApp: App {
    @StateObject var todoViewModel : UserManager = UserManager()
    
    init(){
        FirebaseApp.configure()
        print("Success!")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                
                RootView()
                    
            }
            .environmentObject(todoViewModel)
            
        }
    }
}
