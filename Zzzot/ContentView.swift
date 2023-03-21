//
//  ContentView.swift
//  Zzzot
//
//  Created by Jay Fukumoto on 3/17/23.
//


import SwiftUI

struct ContentView: View {
    @State private var isShowingPopover = false
    @State public var date = Date()
    @StateObject var userCalendar = AppState.shared.userCalendar
    
    var body: some View {
        let _ = userCalendar.initDateDict(date)
        NavigationView{
            TabView {
                SleepView(date: self.$date)
                    .tabItem {
                        Label("Sleep", systemImage: "powersleep")
                    }
                CalendarView(date: self.$date)
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
    @Binding public var date : Date
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 45) {
            Text("You slept \(String(format: "%.2f", AppState.shared.sleepDatabase.getData(date: date).Time)) hours last night.")
                .font(.title)
                .fontWeight(.ultraLight)
            Text("This week on average you slept \(AppState.shared.sleepDatabase.averageSleep(startDate: date, lastXDays: 7)) hours.")
                .font(.title)
                .fontWeight(.ultraLight)
            
            Text("This month on average you slept \(AppState.shared.sleepDatabase.averageSleep(startDate: date, lastXDays: 30)) hours.")
                .font(.title)
                .fontWeight(.ultraLight)
            
            Text("This year you slept an average of \(AppState.shared.sleepDatabase.averageSleep(startDate: date, lastXDays: 365)) hours.")
                .font(.title)
                .fontWeight(.ultraLight)
            Text("You should sleep at \(AppState.shared.sleepDatabase.stringTime) if you want to get the recommended amount of sleep.")
                .font(.title)
                .fontWeight(.ultraLight)
        }
    }
}

struct CalendarView: View {
    
    @State private var showingAddView = false
    @Binding public var date : Date
    @State private var refreshToggle : Bool = true
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if (refreshToggle){}
                Text("Score: \(Int(0))")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                List {
                    ForEach(AppState.shared.userCalendar.getEventByDay(date)){ e in
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
                    .onDelete(perform: deleteEvent)
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
                AddEventView(refreshToggle: $refreshToggle)
            }
        }
        .navigationViewStyle(.stack)
        /*
        VStack(alignment: .center, spacing: 20){
            DatePicker(
                "Due Date",
                selection: $todoDate,
                displayedComponents: [.date]
            )
            HStack{
                Text("Category")
                Spacer()
                Picker("Select a paint color", selection: $selection) {
                    ForEach(colors, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
            }
            
            HStack{
                Text("Task")
                Spacer()
                TextField(
                    "Go to class at...",
                    text: $username
                )
                .textFieldStyle(.roundedBorder)
            }
            HStack{
                Text("Notes")
                ZStack {
                    TextEditor(text: $editorText)
                    Text(editorText).opacity(0).padding(.all,8)
                }
                .shadow(radius: 1)
            }
        }*/
        .padding()
    }
    private func deleteEvent(offsets: IndexSet){
        //pass
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
