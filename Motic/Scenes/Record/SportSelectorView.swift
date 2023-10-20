//
//  SportSelectorView.swift
//  Motic
//
//  Created by Ciao Chiang on 2023/10/10.
//

import SwiftUI

struct SportSelectorView: View {
    @StateObject var viewModel: SportSelectorViewModel
    @Binding var isPresented: Bool
    
    var onSelected: (_ sport: SportType) -> Void
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    // Favorite Section
                    Section("Favorite") {
                        ForEach(viewModel.favorites, id: \.self) { sport in
                            HStack {
                                Image(systemName: "checkmark")
                                    .opacity(viewModel.selectedSport == sport ? 1.0 : 0.0)
                                Text(sport.description.capitalized)
                                    .fontWeight(viewModel.selectedSport == sport ? .semibold : .none)
                                    .onTapGesture {
                                        viewModel.selectSport(sport: sport)
                                        
                                        onSelected(sport)
                                        
                                        // Dismiss
                                        isPresented.toggle()
                                    }
                            }
                        }
                        .onDelete(perform: deleteFavorite)
                    }
                    
                    Section("Sports") {
                        ForEach(viewModel.sports, id: \.self) { sport in
                            HStack {
                                Image(systemName: "checkmark")
                                    .opacity(viewModel.selectedSport == sport ? 1.0 : 0.0)
                                Text(sport.description.capitalized)
                                    .fontWeight(viewModel.selectedSport == sport ? .semibold : .none)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        viewModel.selectSport(sport: sport)
                                        onSelected(sport)
                                        
                                        // Dismiss
                                        isPresented.toggle()
                                    }
                                Spacer()
                                Image(systemName: viewModel.favorites.contains(sport) ? "heart.fill" : "heart")
                                    .foregroundColor(.themeStyle.theme.primary)
                                    .frame(width: 40, height: 40)
                                    .onTapGesture {
                                        viewModel.handleFavoriteAction(sport: sport)
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("Choose Sport")
            }
        }
    }
    
    func deleteFavorite(indexSet: IndexSet) {
        viewModel.favorites.remove(atOffsets: indexSet)
    }
}

struct SportSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let dependency = SportSelectorViewModelDependencyImp(logger: Mocks.logger)
        let viewModel = SportSelectorViewModel(dependency: dependency)
        SportSelectorView(viewModel: viewModel, isPresented: .constant(false)) { sport in
            print("Select sport: \(sport.description)")
        }
    }
}
