//
//  AppState.swift
//  Zzzot
//
//  Created by Jay Fukumoto on 3/18/23.
//

import Foundation

class AppState : ObservableObject {
    static let shared = AppState()
    
    @Published var sleepDatabase = LocalStorageInterface.retrieveUserSleepDatabase()
    @Published var userCalendar = LocalStorageInterface.retrieveCalendarDatabase()
    @Published var personalModel = LocalStorageInterface.retrievePersonalModel()
    @Published var recommendations : recs? = nil
    @Published var todaysData : SleepData? = nil
}
