//
//  AddEventIView.swift
//  Zzzot
//
//  Created by Chris Ruan on 3/17/23.
//

import SwiftUI

struct AddEventView: View {
    @Environment (\.dismiss) var dismm
    
    @State private var todoDate = Date()
    @State private var selection = "Red"
    let colors = ["Red", "Green", "Blue", "Black", "Tartan"]
    @State private var username: String = ""
    @State private var editorText: String = ""
    @State private var name = ""
    @State private var calories: Double = 0
    @EnvironmentObject var userCalendar: UserCalendar

    
    var body: some View {
        Form {
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
            }
            Section{
                HStack{
                    Spacer()
                    Button("Submit"){
                        userCalendar.addEvent(userCalendar.incEventID(), todoDate, username, editorText)
                        dismm()
                    }
                    Spacer()
                    
                }
            }
        }
    }
}
