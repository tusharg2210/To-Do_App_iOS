//
//  HomePage.swift
//  DO DO
//
//  Created by Tushar Gupta on 07/10/24.
//

import SwiftUI

@MainActor
final class HomePageViewModel: ObservableObject {
    
    @Published private(set) var user : Users? = nil
    
    
    func loadCurrentUser()  async throws{
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
        
    }
    
    
}


struct HomePage: View {
    
    @StateObject private var viewModel = HomePageViewModel()
    @Binding var isSignIn: Bool
    @State private var animate: Bool = false
    @State var showAlert: Bool = false
    @State var itemToDelete: String? = nil
    
    let gradiant : RadialGradient = RadialGradient(colors: [Color.indigo.opacity(0.5),Color.purple.opacity(0.5)],
                                                   center: .top,
                                                   startRadius: 10,
                                                   endRadius: 300)
    
    var body: some View {
        ScrollView {
            VStack {
                if let user = viewModel.user {
                    if let list = user.items {
                        if list.isEmpty {
                            Spacer()
                            emptyTaskView()
                            
                        }
                        else {
                            GeometryReader { geometry in
                                let columns = generateColumns(for: geometry.size.width)
                                LazyVGrid(columns: columns, alignment: .center, spacing: 15) {
                                    ForEach(list) { item in
                                        NavigationLink {
                                            ListExpandView(title: item.title,
                                                           bodyy: item.bodyy,
                                                           ispriority: item.isPriority,
                                                           iscomplete: item.isCompleted,
                                                           userId: user.userId,
                                                           itemId: item.id)
                                        } label: {
                                            ListUI(bodyy: item.bodyy,
                                                   title: item.title,
                                                   priority: item.isPriority,
                                                   completed: item.isCompleted)
                                            .contextMenu {
                                                showButtons(userId: user.userId, itemID: item.id, prior: item.isPriority, completed: item.isCompleted)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Home")
        .toolbar {
            
            ToolbarItem(placement: .bottomBar) {
                NavigationLink {
                    AddListView()
                } label: {
                    Image(systemName: "plus.app.fill")
                        .foregroundStyle(gradiant)
                        .font(.title)
                }
            }
            
            ToolbarItem(placement: .topBarLeading) {
                Text("To Do")
                    .font(.title2)
                    .fontDesign(.serif)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AddListView()
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    ProfileView(isSignIn: $isSignIn)
                } label: {
                    Image(systemName: "person.crop.circle")
                        .font(.headline)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Delete"),
                message: Text("Are you sure you want to delete this task?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    if let itemId = itemToDelete {
                        Task {
                            try await deleteItem(itemId: itemId)
                        }
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    NavigationStack {
        HomePage(isSignIn: .constant(false))
    }
}

extension HomePage {
    
    func emptyTaskView() -> some View {
        VStack(alignment: .center, spacing: 40) {
            Text("No Items!")
                .font(.title)
                .fontDesign(.serif)
                .bold()
                .padding()
            NavigationLink {
                AddListView()
            } label: {
                Text("Add Items")
                    .padding()
                    .padding(.horizontal, 20)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .background(gradiant)
                    .clipShape(Capsule())
                    .shadow(color: Color.gray.opacity(0.5), radius: 3, x: 3, y: 3)
            }
            
            
            Spacer()
        }
        .fontDesign(.serif)
    }
    
    
    
    
    
    func generateColumns(for width: CGFloat) -> [GridItem] {
        let numberOfColumns = max(Int(width / 200), 2)
        return Array(repeating: GridItem(.flexible(), spacing: nil, alignment: .center), count: numberOfColumns)
    }
    
    func showButtons(userId: String, itemID: String, prior: Bool, completed: Bool) -> some View {
        VStack {
            Button(prior ? "Low Priority" : "High Priority") {
                Task {
                    try await UserManager.shared.updatePriorityStatus(userId: userId, itemId: itemID, isPriority: !prior)
                    try await viewModel.loadCurrentUser()
                }
            }
            Button(completed ? "Incomplete" : "Completed") {
                Task {
                    try await UserManager.shared.updateCompletionStatus(userId: userId, itemId: itemID, isCompleted: !completed)
                    try await viewModel.loadCurrentUser()
                }
            }
            Button {
                itemToDelete = itemID
                showAlert = true
            } label: {
                HStack {
                    Text("Delete")
                    Spacer()
                    Image(systemName: "trash")
                }
                .foregroundStyle(Color.red)
            }
        }
    }
    
    func deleteItem(itemId: String) async throws {
        if let user = viewModel.user {
            try await UserManager.shared.deleteList(userId: user.userId, itemId: itemId)
            try await viewModel.loadCurrentUser()
        }
    }
}
