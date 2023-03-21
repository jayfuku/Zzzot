//
//  ContentView.swift
//  Zzzot
//
//  Created by Jay Fukumoto on 3/17/23.
//


import SwiftUI

struct ContentView: View {
    @State private var isShowingPopover = false
    @State private var date = Date()
    @StateObject var userCalendar = UserCalendar()
    
    var body: some View {
        let _ = userCalendar.initDateDict(date)
        NavigationView{
            TabView {
                SleepView()
                    .tabItem {
                        Label("Sleep", systemImage: "powersleep")
                    }
                CalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // <2>
                ToolbarItem(placement: .principal) { // <3>
                    HStack{
                        Text("Zzzot").font(.system(size: 45, weight: .bold, design: .default))
                            .padding(.horizontal,50)
                        Button(action:{self.isShowingPopover = true}){
                            Image(systemName: "calendar")
                                .font(Font.system(.largeTitle))
                        }
                        .popover(isPresented: $isShowingPopover) {
                            DatePicker(
                                "Pick a date to view:",
                                selection: $date,
                                displayedComponents: [.date]
                                
                            )
                            .padding()
                        }
                    }
                    
                }
            }
            .opacity(1)
        }
        .environmentObject(userCalendar)
        .padding()
    }
}
struct SleepView: View {
    var body: some View {
        
        VStack {
            Text("You slept ____ hours last night")
            Text("This week on average you slept 5 hours")
            
            Text("This month on average you slept 6 hours")
            
            Text("Since you started tracking sleep, you slept an average of 6 hours")
            
            Text("You should sleep at 1:00 AM if you want to make it to ____ tomorrow.")
                .padding()
        }
    }
}

struct CalendarView: View {
    
    @State private var showingAddView = false
    @State private var date = Date()
    
    @EnvironmentObject var userCalendar: UserCalendar
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Score: \(Int(0))")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                List {
                    ForEach(userCalendar.getEventByDay(date)){ e in
                        let _ = print("Justin steal the data and did not work")
                        NavigationLink(destination: Text("\(e.desc)")) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6){
                                    Text(e.name)
                                        .bold()
                                }
                                Spacer()
                                Text("\(e.time)")
                                    .foregroundColor(.gray)
                                    .italic()
                            }
                        }
                    }
                    .onDelete{ offsets in
                        AppState.shared.userCalendar.removeEventByDay(date, offsets.first!)
                        refreshToggle.toggle()
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingAddView.toggle()
                    } label: {
                        Label("Add Event", systemImage: "plus.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading){
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAddView){
                AddEventView()
            }
        }
        .navigationViewStyle(.stack)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
