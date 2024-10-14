//
//  ListUI.swift
//  DO DO
//
//  Created by Tushar Gupta on 12/10/24.
//

import SwiftUI

struct ListUI: View {
    let bodyy : String
    let title : String
    var priority : Bool
    var completed : Bool
    
    let gradiant : RadialGradient = RadialGradient(colors: [Color.indigo.opacity(0.5),Color.purple.opacity(0.5)],
                                                   center: .top,
                                                   startRadius: 10,
                                                   endRadius: 300)
 
    
    var body: some View {
        ZStack(alignment : .center){
            VStack(alignment : .leading, spacing: 10){
                
                Text(title)
                    .font(.headline)
                Text(bodyy)
                    .font(.footnote)
                Spacer()
            }.multilineTextAlignment(.leading)
                .fontDesign(.serif)
                .padding(.horizontal,30)
                .padding(.top,20)
                .padding(.bottom,10)
                .frame(width: 180, height: 150 ,alignment: .leading)
                .foregroundStyle(Color.primary)
                .opacity(completed ? 0.4 : 1)
                
            
        }
        .background( gradiant)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: priority ? "star.fill" : "star")
                .foregroundStyle( priority ?  Color.yellow : Color.white)
                .font(.title3)
                .offset(x : -6, y : -10)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle( Color.white)
                .font(.title3)
                .offset(x : -6, y : 7)
        }
      
        
        
    }
}

#Preview {
    ListUI(bodyy: "hii", title: "Titletttttttttttt", priority: .random(), completed: .random())
}
