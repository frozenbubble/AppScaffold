import Foundation
import BackgroundTasks
import SwiftData

@available(iOS 17, *)
public class BackgroundTaskManager {
    let taskId: String
    let action: () throws -> Void
    
    public init(taskId: String, action: @escaping () throws -> Void) {
        self.taskId = taskId
        self.action = action
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }
    }
    
    func handleBackgroundTask(task: BGProcessingTask) {
        scheduleBackgroundTask()
        
        task.expirationHandler = { }
        let isSuccess = self.performBackgroundTask()
        task.setTaskCompleted(success: true)
    }
    
    func performBackgroundTask() -> Bool {
        do {
            try action()
            return true
        } catch {
            return false
        }
    }
    
    // debug: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"REMINDER_REFRESH"]
    func scheduleBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: taskId)
        request.earliestBeginDate = .now.addHours(3)
        // Optional
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            applog.error("Could not schedule background task: \(error)")
        }
    }
}
