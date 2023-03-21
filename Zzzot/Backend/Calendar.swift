	//
//  Calendar.swift
//  cs125BackendTesting
//
//  Created by Jay Fukumoto on 2/22/23.
//

import Foundation

typealias calendarStorage = Dictionary<Int, Dictionary<Int, Dictionary<Int, [CalendarEvent]>>>

struct calendarLocalStorage : Codable{
    var calendar : calendarStorage
    var eventIDCount : Int
}

class UserCalendar : Codable, ObservableObject{
    //Class representation for calendar
    //Should be singleton
    
    // Year -> Month -> Day -> [CalendarEvent]
    private var calendar: Dictionary<Int, Dictionary<Int, Dictionary<Int, [CalendarEvent]>>>
    private var eventIDCount: Int
    static var initialized: Bool = false
    
    init(){
        assert(!UserCalendar.initialized, "ERROR: UserCalendar has already been created")
        self.calendar = Dictionary<Int, Dictionary<Int, Dictionary<Int, [CalendarEvent]>>>()
        self.eventIDCount = 0
    }
    
    public func _clearCalender() -> Void {
        // Clear the calendar
        self.calendar = Dictionary<Int, Dictionary<Int, Dictionary<Int, [CalendarEvent]>>>()
    }
    
    public func incEventID() -> String{
        self.eventIDCount += 1
        return String(self.eventIDCount)
    }
    
    public func initDateDict(_ date: Date){
        //Add an event to the calendar given a date name and description
        //TODO: What should happen if the event already exists on that day and time?
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: date)
        let year_: Int = components.year!
        let month_: Int = components.month!
        let day_: Int = components.day!
        
        if (self.calendar[year_] == nil){
            self.calendar[year_] = Dictionary<Int, Dictionary<Int, [CalendarEvent]>>()
        }
        if (self.calendar[year_]![month_] == nil) {
            self.calendar[year_]![month_] = Dictionary<Int, [CalendarEvent]>()
        }
        if (self.calendar[year_]![month_]![day_] == nil){
            self.calendar[year_]![month_]![day_] = []
        }
        
    }
    
    public func addEvent(_ id: String, _ date: Date, _ name: String, _ desc: String){
        //Add an event to the calendar given a date name and description
        //TODO: What should happen if the event already exists on that day and time?
        let event = CalendarEvent(id: id, time: date, name: name, desc: desc)
     
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: date)
        let year_: Int = components.year!
        let month_: Int = components.month!
        let day_: Int = components.day!
        
        if (self.calendar[year_] == nil){
            self.calendar[year_] = Dictionary<Int, Dictionary<Int, [CalendarEvent]>>()
        }
        if (self.calendar[year_]![month_] == nil) {
            self.calendar[year_]![month_] = Dictionary<Int, [CalendarEvent]>()
        }
        if (self.calendar[year_]![month_]![day_] == nil){
            self.calendar[year_]![month_]![day_] = []
        }
        
        self.calendar[year_]![month_]![day_]!.append(event)
        print(self.calendar)
    }
    
    public func getEventByDay(_ date: Date) -> [CalendarEvent]{
        // Get all events in a day
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: date)
        let year_: Int? = components.year
        let month_: Int? = components.month
        let day_: Int? = components.day
        
        if (self.calendar[year_!] == nil){
            return []
        }
        if (self.calendar[year_!]![month_!] == nil){
            return []
        }
        if (self.calendar[year_!]![month_!]![day_!] == nil){
            return []
        }
        
        return self.calendar[year_!]![month_!]![day_!]!
    }
    
    public func removeEventByDayOnIndex(_ date: Date, _ index: Int){
        // Get all events in a day
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .day, .month], from: date)
        let year_: Int? = components.year
        let month_: Int? = components.month
        let day_: Int? = components.day
        
        self.calendar[year_!]![month_!]![day_!]!.remove(at: index)
    }
        
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let obj : calendarLocalStorage = calendarLocalStorage(calendar: self.calendar, eventIDCount: self.eventIDCount)
        try container.encode(obj)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let obj = try container.decode(calendarLocalStorage.self)
        self.calendar = obj.calendar
        self.eventIDCount = obj.eventIDCount
    }
}
