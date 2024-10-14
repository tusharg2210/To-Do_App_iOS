//
//  SignUpView.swift
//  DO DO
//
//  Created by Tushar Gupta on 08/10/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift


struct SignUpView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var isSignIn : Bool
    
    @State private var eangle : Double = 0
    @State private var onboarding : Bool = false
    @State private var position : CGFloat = 0
    
    
    let gradiant : RadialGradient = RadialGradient(colors: [Color.indigo.opacity(0.5),Color.purple.opacity(0.4)],
                                                   center: .top,
                                                   startRadius: 100,
                                                   endRadius: 1100)
    let gradiant1 : RadialGradient = RadialGradient(colors: [Color.purple.opacity(0.7),Color.indigo.opacity(0.8)],
                                                    center: .topTrailing,
                                                    startRadius: 10,
                                                    endRadius: 300)
 
    
    let transition : AnyTransition = .asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom))
    
    var body: some View {
        ZStack{
            gradiant
                .ignoresSafeArea()
            
            
            VStack{
                
                
                splashScreen
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                            withAnimation(.spring){
                                position = -60
                            }
                            
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6){
                            withAnimation(.spring){
                                onboarding = true
                            }
                            
                        }
                    }
                
                if onboarding {
                    SignUpButton
                        .transition(transition)
                        .offset(y: 200)
                }
               
                
                
            }
           
        }
        
    }
}

#Preview {
    SignUpView(isSignIn: .constant(false))
}
extension SignUpView{
    
    private var appName : some View{
        VStack{
            Text("To Do")
                .font(.custom("TO DO", size: 40))
                .fontWeight(.heavy)
                .fontDesign(.serif)
                .foregroundStyle(Color.indigo.opacity(0.7))
        }
        .transition(transition)
        
    }
    
    private var SignUpButton : some View{
        VStack(alignment: .center){
           
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(
                scheme: .light, style: .wide, state: .normal),
                                      action: {
                       Task{
                           do{
                               try await viewModel.googleSignIN()
                               isSignIn = false
                           }
                           catch{
                               print(Error.self)
                           }
                       }
                   })
            
            .clipShape(Capsule())
            .padding(.horizontal,105)
                   
        }
        
    }
    
    
    private var splashScreen : some View{
        
        VStack(spacing : 20){
            ZStack{
                ArcShapes(endAngle: eangle)
                    .stroke(lineWidth:5)
                    .frame(width: 200, height: 200)
                    .foregroundStyle(gradiant1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            self.eangle = 310
                        }
    //                .rotationEffect(.degrees(150))
                
            }
                if eangle == 310 {
                    withAnimation(.easeInOut){
                        CheckMark()
                            .stroke(lineWidth: 25)
                            .frame(width: 250, height: 250)
                            .foregroundStyle(gradiant1)
                            .transition(.opacity)  // Fade in when shown
                        
                    }
                }
            }
            if onboarding {
                
                appName
                    .transition(transition)
            }
            
                
        }
        .frame(width: 220, height: 220)
        .offset(y: position)
    }
    
    
    
    
    
}

struct ArcShapes: Shape {
    var startAngle: Angle = .degrees(0)
    var endAngle: Double
    var animatableData: Double {
            get { endAngle }
            set { endAngle = newValue }
        }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: .degrees(endAngle), clockwise: false)
        return path
    }
    
   
    
    
}

struct CheckMark: Shape {
    
    func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Checkmark coordinates relative to the frame size
            let start = CGPoint(x: rect.width * 0.25, y: rect.height * 0.5)
            let mid = CGPoint(x: rect.width * 0.45, y: rect.height * 0.7)
        let end = CGPoint(x: rect.width * 0.88 , y: rect.height * 0.27)
            
            path.move(to: start)
            path.addLine(to: mid)
            path.addLine(to: end)
            
            return path
        }

}


