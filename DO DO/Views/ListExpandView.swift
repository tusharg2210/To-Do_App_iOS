//
//  ListExpandView.swift
//  DO DO
//
//  Created by Tushar Gupta on 13/10/24.
//

import SwiftUI

@MainActor
final class ListexpandModel : ObservableObject {
    @Published private(set) var user : Users? = nil
    
    
    func loadCurrentUser()  async throws{
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
}

struct ListExpandView: View {
    @State var title : String
    @State var bodyy : String
    @State var ispriority : Bool
    @State var iscomplete : Bool
    @State var userId : String
    @State var itemId : String
    
    @StateObject private var listexpandModel = ListexpandModel()
    var body: some View {
        ScrollView{
            VStack(alignment : .leading){
                Text(bodyy)
                    .font(.title3)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
        }
        .task {
            try? await listexpandModel.loadCurrentUser()
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task{
                        iscomplete.toggle()
                        do{
                            try await UserManager.shared.updateCompletionStatus(userId: userId, itemId: itemId, isCompleted: iscomplete)
                            try await listexpandModel.loadCurrentUser()
                        }
                        catch{
                            iscomplete.toggle()
                            print("Error updating completion status:", error.localizedDescription)
                        }
                    }
                } label: {
                    Image(systemName: iscomplete ? "checkmark.circle.fill" : "checkmark.circle")
                        .foregroundStyle(iscomplete ? Color.indigo : Color.gray)
                        .font(.headline)
                }
                
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task{
                        ispriority.toggle()
                        do{
                            try await UserManager.shared.updatePriorityStatus(userId: userId, itemId: itemId, isPriority: ispriority)
                            try await listexpandModel.loadCurrentUser()
                        }
                        catch{
                            ispriority.toggle()
                            print("Error updating priority status:", error.localizedDescription)
                        }
                    }
                } label: {
                    Image(systemName: ispriority ? "star.fill" : "star")
                        .foregroundStyle(Color.yellow)
                        .font(.headline)
                }
                
            }
        }
    }
}

#Preview {
    NavigationView {
        ListExpandView(title: "title", bodyy: "hii EveryOne", ispriority: false, iscomplete: false, userId: " ", itemId: " ")
        
    }
}
