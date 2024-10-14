//
//  RootView.swift
//  DO DO
//
//  Created by Tushar Gupta on 08/10/24.
//

import SwiftUI

struct RootView: View {
    
    @State private var isSignIn: Bool = false
    
    var body: some View {
        VStack{
            if !isSignIn {
                HomePage(isSignIn: $isSignIn)
                
            }
               
        }
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.isSignIn = authUser == nil ? true : false
        }
        .fullScreenCover(isPresented: $isSignIn, content: {
            NavigationStack{
                SignUpView(isSignIn: $isSignIn)
            }
        })
    }
}

#Preview {
    RootView()
}
