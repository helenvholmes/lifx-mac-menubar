// lifx-notifier — posts one notification with the LIFX Menu Bar icon, then quits.
//
// The plugin runs it as:  lifx-notifier "<title>" "<body>"
// Exit status 0 means the notification was posted. Anything else (notifications
// turned off, permission denied, timed out) tells the plugin to fall back to SwiftBar.
//
// Build it with ./scripts/build-notifier.sh

import Foundation
import UserNotifications

let args = Array(CommandLine.arguments.dropFirst())
// No arguments: opened from Finder or by clicking one of its notifications. Nothing to do.
guard args.count >= 2 else { exit(0) }

let content = UNMutableNotificationContent()
content.title = args[0]
content.body = args[1]
content.sound = .default

let center = UNUserNotificationCenter.current()
let done = DispatchSemaphore(value: 0)
var posted = false

// The first run asks the user to allow notifications; later runs answer right away.
center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
    guard granted else { done.signal(); return }
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
    center.add(request) { error in
        posted = (error == nil)
        done.signal()
    }
}

// Give the user time to answer the one-time permission prompt.
if done.wait(timeout: .now() + 120) == .timedOut { exit(3) }
exit(posted ? 0 : 2)
