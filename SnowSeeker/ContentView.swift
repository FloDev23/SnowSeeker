//
//  ContentView.swift
//  SnowSeeker
//
//  Created by Floriano Fraccastoro on 03/03/23.
//

import SwiftUI

struct ContentView: View {
    let resorts: [Resort] = Bundle.main.decode("resorts.json")
    @State private var searchResort = ""
    @State private var sortOrder: SortOrder = .default
    @State private var isShowingSort = false
    @StateObject var favorites = Favorites()
    
    enum SortOrder {
        case `default`
        case alphabetical
        case byCountry
        
        func sorter(lhs: Resort, rhs: Resort) -> Bool {
            switch self {
            case .default:
                return false
            case .alphabetical:
                return lhs.name < rhs.name
            case .byCountry:
                return lhs.country < rhs.country
            }
        }
    }
    
    var body: some View {
        NavigationView{
            List(filteredResorts){ resort in
                NavigationLink{
                    ResortView(resort: resort)
                } label: {
                    HStack{
                        Image(resort.country)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 25)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.black, lineWidth: 1))
                        VStack(alignment: .leading){
                            Text(resort.name)
                                .font(.headline)
                            Text("\(resort.runs) runs")
                                .foregroundColor(.secondary)
                        }
                        if favorites.contains(resort) {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .accessibilityLabel("This is a favorite resort")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Resorts")
            .searchable(text: $searchResort, prompt: "Search for a resort")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu("Sort") {
                        Button("Default") { sortOrder = .default }
                        Button("Alphabetical") { sortOrder = .alphabetical }
                        Button("By Country") { sortOrder = .byCountry }
                    }
                }
            }
            WelcomeView()
        }
        .environmentObject(favorites)
        .phoneOnlyStackNavigationView()
    }
    
    var filteredResorts: [Resort] {
        let filteredResorts = searchResort.isEmpty ? resorts : resorts.filter { $0.name.localizedCaseInsensitiveContains(searchResort) }
        
        return filteredResorts.sorted(by: sortOrder.sorter)
    }
}

//elimina il menu laterale a scomparsa su tutti i tipi di iPhone mentre lascia il menu laterale sugli iPad
extension View {
    @ViewBuilder func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
