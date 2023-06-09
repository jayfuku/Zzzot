//
//  ZzzotApp.swift
//  Zzzot
//
//  Created by Jay Fukumoto on 3/17/23.
//

import SwiftUI
import HealthKit

typealias recs = [(recommendations, recommendationData, Double)]

@main
struct ZzzotApp: App {
    @State private var HKStore : HKHealthStore = HKHealthStore()
    @Environment(\.scenePhase) private var scenePhase
    
    init(){
        let typesToRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        ])
        

        
        self.HKStore.requestAuthorization(toShare: nil, read: typesToRead)
        { (success, error) in
                if !success{
                print("Authorization failed")
            }
            else if success{
                print("Authorization succeeded")
            }
        }
        
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView().onAppear{
                self.queryData()
            }.onChange(of: scenePhase){
                phase in
                if phase == .background {
                    LocalStorageInterface.setPersonalModel(AppState.shared.personalModel)
                    LocalStorageInterface.setCalendarDatabase(AppState.shared.userCalendar)
                    LocalStorageInterface.setUserSleepDatabase(AppState.shared.sleepDatabase)
                }
            }
        }
    }
    
    private func queryData(){
        if !HKHealthStore.isHealthDataAvailable(){
            return
        }
        
        var retSleepData = SleepData(Time: -1, slept: Date.now, woke: Date.now)
        
        let sleepType = HKCategoryType(.sleepAnalysis)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 20, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) in
                retSleepData.Time = 1
                if error != nil{
                    print("Error")
                    return
                }
                if let result = tmpResult{
                    if (result.count == 0) {
                        //Do nothing if no data was able to be obtained
                        return
                    }
                    if let sample = result[0] as? HKCategorySample{
                        retSleepData.slept = sample.startDate
                        retSleepData.woke = sample.endDate
                    }
                    for item in result[1...] {
                        if let sample = item as? HKCategorySample{
                            
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue)
                            
                            print("Healthkit Sleep:\n\t \(sample.startDate)\n\t \(sample.endDate) \n\t- value \(value)")
                            if (self.timeBetweenDates(retSleepData.slept, sample.endDate) <= 1.5){
                                retSleepData.slept = sample.startDate
                            }
                            else{
                                break
                            }
                        }
                    }
                    retSleepData.Time = self.timeBetweenDates(retSleepData.woke, retSleepData.slept)
                    print("Final sleep time \n\t\(retSleepData.woke)\n\t\(retSleepData.slept)")
                    AppState.shared.sleepDatabase.addData(Date(), retSleepData)
                    AppState.shared.personalModel.updateAll(data: retSleepData)
                    let recAlgo = RecommendationAlgorithm(AppState.shared.personalModel)
                    AppState.shared.recommendations = recAlgo.recommend()
                }
        }
        
        self.HKStore.execute(sampleQuery)
        do {
            try AppState.shared.personalModel.setSex(self.HKStore.biologicalSex().biologicalSex)
            try AppState.shared.personalModel.setDOB(self.HKStore.dateOfBirthComponents())
        }
        catch {
            print("Error retrieving bioglogical sex or DOB")
        }
        
    }
    
    private func timeBetweenDates(_ endDate: Date, _ startDate: Date) -> Double {
        return endDate.timeIntervalSince(startDate) / 3600
    }
}

