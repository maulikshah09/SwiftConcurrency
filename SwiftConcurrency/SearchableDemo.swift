//
//  SearchableDemo.swift
//  SwiftConcurrency
//
//  Created by Maulik Shah on 3/10/25.
//

import SwiftUI
import Combine

struct Resturant : Hashable, Identifiable{
    let id : String
    let title : String
    let cuisine : CuisineOption
}

enum CuisineOption : String{
    case american, italian, japanese
}

enum SearchScopeOption : Hashable{
    case all
    case cuisine(option: CuisineOption)
    
    var title : String{
        switch self{
        case .all:
            return "All"
        case .cuisine(option: let option):
            return option.rawValue.capitalized
        }
    }
}

final class ResturantManager {
    
    func  getAllResturant() async throws -> [Resturant]{
        
        [
            Resturant(id: "1", title: "Burger Shack", cuisine: .american),
            Resturant(id: "2", title: "pasta palace", cuisine: .italian),
            Resturant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Resturant(id: "4", title: "Local market", cuisine: .american)
        ]
        
    }
}

@MainActor
final class SearchableViewModel : ObservableObject{
    
    @Published private(set) var allResturants : [Resturant] = []
    @Published private(set) var filteredResturants : [Resturant] = []
    @Published var searchScope : SearchScopeOption = .all

    @Published private(set) var allSearchScope : [SearchScopeOption] = []
    
    @Published var searchText : String = ""
    private var cancellables = Set<AnyCancellable>()
    
    let manager = ResturantManager()
    
    var isSearching : Bool{
        !searchText.isEmpty
    }
    
    var showSearchSuggestion : Bool{
        searchText.count < 3
    }
    
    init() {
        addSubscriber()
    }
    
    private func addSubscriber(){
        $searchText
            .combineLatest($searchScope)
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] searchText,searchScope in
                self?.filterResturants(searchText: searchText, searchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterResturants(searchText : String,searchScope : SearchScopeOption){
        guard !searchText.isEmpty else {
            filteredResturants = []
            self.searchScope = .all
            return
        }
        
        // filter on seach scope
        var restautantsInScope = allResturants
        
        switch searchScope {
        case .all:
            break
        case .cuisine(option: let option):
            restautantsInScope = allResturants.filter{ restaurant in
                return restaurant.cuisine == option
            }
        }
        
        
        // filter on search text
        let search =  searchText.lowercased()
        filteredResturants  =  restautantsInScope.filter {
            $0.title.lowercased().contains(search)  ||
            $0.cuisine.rawValue.lowercased().contains(search)
        }
    }
    
    func loadResturants() async{
        do {
            allResturants = try await manager.getAllResturant()
            
            let allCuisines = Set(allResturants.map { $0.cuisine })
           
            allSearchScope = [.all] + allCuisines.map{option in
                SearchScopeOption.cuisine(option: option)
            }
        }
        catch {
            print(error)
        }
    }
    
    func getSearchSuggestions() -> [String]{
        guard showSearchSuggestion else{
            return []
        }
        
        var suggestions: [String] = []
        let search = searchText.lowercased()
        if search.contains("pa"){
            suggestions.append("Pasta")
        }
       
        if search.contains("su"){
            suggestions.append("Sushi")
        }
        
        if search.contains("bu"){
            suggestions.append("Burger")
        }
        
        if search.contains("pa"){
            suggestions.append("Pasta")
        }
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)

        return suggestions
    }
    
    func getRestaurantSuggestion() -> [Resturant] {
        guard showSearchSuggestion else{
            return []
        }
        
        var suggestions: [Resturant] = []
        let search = searchText.lowercased()
        
        if search.contains("ita"){
            suggestions.append(contentsOf:
                allResturants.filter { $0.cuisine == .italian})
        }
       
        if search.contains("jap"){
            suggestions.append(contentsOf:
                                allResturants.filter { $0.cuisine == .japanese})
        }
        
        return suggestions
    }
}

 

struct SearchableDemo: View {
    @StateObject private var viewModel = SearchableViewModel()
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        ScrollView{
            VStack(spacing: 20){
                ForEach(viewModel.isSearching ? viewModel.filteredResturants : viewModel.allResturants) { resturant in
                   
                    NavigationLink(value: resturant) {
                        resturantRow(resturant: resturant)
                    }
                }
            }
            .padding()
        }
        .searchable(text: $viewModel.searchText ,placement: .automatic, prompt: Text("Search Restaurants..."))
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScope, id: \.self) {scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        .searchSuggestions({
            ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                Text(suggestion)
                    .searchCompletion(suggestion)
            }
            
            ForEach(viewModel.getRestaurantSuggestion(), id: \.self) { suggestion in
                NavigationLink(value : suggestion){
                    Text(suggestion.title)
                }
            }
        })
        .task {
            await viewModel.loadResturants()
        }
        
      //  .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Restsurants")
        .navigationDestination(for: Resturant.self) { resturant in
            Text(resturant.title.uppercased())
        }
    }
    
    private func resturantRow(resturant: Resturant) -> some View {
        VStack(alignment: .leading,spacing: 10) {
            Text(resturant.title)
                .font(.headline)
                .foregroundStyle(.red)
            Text(resturant.cuisine.rawValue)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity,alignment: .leading)
        .background(.black.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack{
        SearchableDemo()
    }
}
