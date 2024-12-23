//import Foundation
//import BackgroundTasks
//import SwiftData
//
//fileprivate let reminderRefreshTask = "REMINDER_REFRESH"
//
//@available(iOS 17, *)
//class RefresherTaskManager<T: PersistentModel> {
//    
//    let refresherActor: ReminderRefresherActor<T>
//    
//    init(refresherActor: ReminderRefresherActor<T>) {
//        self.refresherActor = refresherActor
//        
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: reminderRefreshTask, using: nil) { task in
//            self.handleBackgroundTask(task: task as! BGProcessingTask)
//        }
//    }
//    
//    func handleBackgroundTask(task: BGProcessingTask) {
//        scheduleBackgroundTask()
//        
//        task.expirationHandler = { }
//        Task {
//            let isSuccess = await self.performBackgroundTask()
//        }
//        task.setTaskCompleted(success: true)
//    }
//    
//    func performBackgroundTask() async -> Bool {
//        await refresherActor.refreshReminders()
//        return true
//    }
//    
//    // debug: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"REMINDER_REFRESH"]
//    func scheduleBackgroundTask() {
//        let request = BGProcessingTaskRequest(identifier: reminderRefreshTask)
//        request.earliestBeginDate = .now.addHours(3)
//        // Optional
//        request.requiresNetworkConnectivity = false
//        request.requiresExternalPower = false
//
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Could not schedule background task: \(error)")
//        }
//    }
//}
