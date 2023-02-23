//
//  ContentView.swift
//  BetWell
//
//  Created by David Mann on 1/15/23.
//

import SwiftUI
import CoreData
import Combine

struct Games: Identifiable {
    let id = UUID()
    let homeTeam: String
    let awayTeam: String
    let overUnder: String
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var  networking = Networking()
    @State var todaysGamesLocal: [NewUpcomingGames] = []
    @State var todaysGames: [NewUpcomingGames] = []
    @State private var searchText = ""
    var body: some View {
        NavigationView {
            List($todaysGames, id: \.statsGameID) { game in
//                NavigationLink {
                    
                    
//                } label: {
                    PlayingTodayView(game: game.wrappedValue)
                    .background( NavigationLink("", destination: TeamDataListView(home: game.home.wrappedValue, away: game.away.wrappedValue, venue: game.venue.wrappedValue)).opacity(0) )
                
//                }
//                .buttonStyle(PlainButtonStyle())
//                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .navigationBarTitle("BetWell", displayMode: .large)
            
        }
        .onAppear() {
            searchText = ""
            todaysGamesLocal = loadData() ?? []
            todaysGames = todaysGamesLocal
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .searchable(text: $searchText, prompt: "Who is playing tonight?")
        .onChange(of: searchText) { index in
            if !index.isEmpty {
                todaysGames = todaysGamesLocal.filter { $0.home.name.contains(searchText) ||  $0.away.name.contains(searchText)}
            } else {
                todaysGames = todaysGamesLocal
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    var searchResults: [NewUpcomingGames] {
        if searchText.isEmpty {
            return todaysGames
        } else {
            return todaysGames.filter { $0.away.name.contains(searchText) ||  $0.home.name.contains(searchText)}
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func loadData() -> [NewUpcomingGames]? {
        guard let url = Bundle.main.url(forResource: "NewGamesSeed", withExtension: "json")
        else {
            print("Json file not found")
            return []
        }
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch (let error) {
            print("cannot get data from url - \(error)")
            return []
        }
        if let data {
            do {
                let games = try JSONDecoder().decode([NewUpcomingGames].self, from: data)
                //                print("games: \(games)")
                return games
            } catch (let error) {
                print("cannot decode - \(error)")
                return []
            }
        } else {
            return []
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct PlayingTodayView: View {
    let game: NewUpcomingGames
    var body: some View {
        HStack(spacing: 0.5) {
            VStack(alignment: .center) {
                Text(game.away.alias)
                    .allowsTightening(true)
                    .lineLimit(2)
                    .scaledToFit()
                    .minimumScaleFactor(0.4)
                Image(game.away.alias)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            .padding(.leading, 10)
            Spacer()
            Text("@")
            Spacer()
            VStack(alignment: .center) {
                Text(game.home.alias)
                    .allowsTightening(true)
                    .lineLimit(2)
                    .scaledToFit()
                    .minimumScaleFactor(0.4)
                Image(game.home.alias)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            Spacer()
            Text(game.venue)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
                .lineLimit(nil)
                .minimumScaleFactor(0.4)
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(.clear)
    }
    
    func parseName(_ string: String) -> String {
        let parsed = string.components(separatedBy: " ")
        if parsed.count >= 2 {
            let count = parsed.count
            print("\(parsed[count - 1])")
            return parsed[parsed.count - 1]
        } else {
            return string
        }
    }
}


//                VStack {
//                    VStack(alignment: .leading) {
//                        Text("My Teams")
//                            .font(.headline)
//                            .fontWeight(.heavy)
//                        ScrollView(.horizontal,showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                ForEach(userdata,id: \.id) { user in
//                                    UserView(user: user)
//                                }
//                            }
//                            .padding(.top, 10)
//                        }
//                        .frame(height: 80)
//                    }
//                    .padding()
//                    VStack(alignment: .leading) {
//                        Text("My Players")
//                            .font(.headline)
//                            .fontWeight(.heavy)
//                        ScrollView(.horizontal,showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                ForEach(userdata,id: \.id) { user in
//                                    UserView(user: user)
//                                }
//                            }
//                            .padding(.top, 10)
//                        }
//                        .frame(height: 80)
//                    }
//                    .padding()
