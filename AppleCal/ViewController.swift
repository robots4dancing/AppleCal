//
//  ViewController.swift
//  AppleCal
//
//  Created by ANI on 3/28/17.
//  Copyright © 2017 ANI. All rights reserved.
//

import UIKit
import EventKit

class ViewController: UIViewController {
    
    let eventStore = EKEventStore()
    
    @IBOutlet weak var calTextField       :UITextField!
    @IBOutlet weak var calStartDatePicker :UIDatePicker!
    @IBOutlet weak var calEndDatePicker   :UIDatePicker!
    @IBOutlet weak var latTextField       :UITextField!
    @IBOutlet weak var lonTextField       :UITextField!
    
    //MARK: - Reminder Methods
    
    @IBAction func createReminder(button: UIBarButtonItem) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.title = calTextField?.text ?? "Unknown"
        let alarm = EKAlarm(absoluteDate: calStartDatePicker.date)
        reminder.addAlarm(alarm)
        if let latText = latTextField.text, let lonText = lonTextField.text, let lat = Double(latText), let lon = Double(lonText) {
            let locAlarm = EKAlarm()
            let ekLoc = EKStructuredLocation(title: "Home")
            let loc = CLLocation(latitude: lat, longitude: lon)
            ekLoc.geoLocation = loc
            ekLoc.radius = 500
            locAlarm.structuredLocation = ekLoc
            locAlarm.proximity = .enter
            reminder.addAlarm(locAlarm)
        }
        do {
            try eventStore.save(reminder, commit: true)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func findReminders(button: UIBarButtonItem) {
        let reminderLists = eventStore.calendars(for: .reminder)
        let predicate = eventStore.predicateForReminders(in: reminderLists)
        eventStore.fetchReminders(matching: predicate) { (reminders) in
            if let count = reminders?.count, count > 0 {
                for reminder in reminders! {
                    print(reminder.title)
                }
            } else {
                print("No Reminders")
            }
        }
    }
    
    //MARK: - Calendar Methods
    
    @IBAction func createCalendarItem(button: UIBarButtonItem) {
        let calEvent = EKEvent(eventStore: eventStore)
        calEvent.calendar = eventStore.defaultCalendarForNewEvents
        calEvent.title = calTextField?.text ?? "Unknown"
        calEvent.startDate = calStartDatePicker.date
        calEvent.endDate = calEndDatePicker.date
        do {
            try eventStore.save(calEvent, span: .thisEvent, commit: true)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func findCalendarItems(button: UIBarButtonItem) {
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: calStartDatePicker.date, end: calEndDatePicker.date, calendars: calendars)
        let events = eventStore.events(matching: predicate)
        if events.count > 0 {
            for event in events {
                print("Title: \(event.title) start: \(event.startDate) end: \(event.endDate)")
            }
        } else {
            print("No Events")
        }
    }
    
    //MARK: - Permission Methods
    
    func requestAccessToEKType(type: EKEntityType) {
        eventStore.requestAccess(to: type) { (accessGranted, error) -> Void in
            if accessGranted {
                print("Granted \(type.rawValue)")
            } else {
                print("Not Granted")
            }
        }
        
    }
    
    func checkEKAuthorizationStatus(type: EKEntityType) {
        let status = EKEventStore.authorizationStatus(for: type)
        switch status {
        case .notDetermined:
            print("Not Determined")
            requestAccessToEKType(type: type)
        case .authorized:
            print("Authorized")
        case .restricted, .denied:
            print("Restricted/Denied")
        }
    }
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEKAuthorizationStatus(type: .event)
        checkEKAuthorizationStatus(type: .reminder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

