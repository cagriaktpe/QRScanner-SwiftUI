//
//  AddEventController.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 20.03.2024.
//

import UIKit
import EventKit
import EventKitUI
import SwiftUI

class AddEventController: UIViewController, EKEventEditViewDelegate {
    let eventStore = EKEventStore()
    var isFirstDidAppear = true
    @Binding var scannedEvent: IdentifiableEKEvent?
    
    init(scannedEvent: Binding<IdentifiableEKEvent?>) {
        self._scannedEvent = scannedEvent
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
        parent?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard isFirstDidAppear else {
            return
        }

        let event = EKEvent(eventStore: eventStore)
        
        if let scannedEvent = scannedEvent {
            event.title = scannedEvent.event.title
            event.startDate = scannedEvent.event.startDate
            event.endDate = scannedEvent.event.endDate
            event.notes = scannedEvent.event.notes
            event.url = scannedEvent.event.url
            event.location = scannedEvent.event.location
        }
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let controller = EKEventEditViewController()
        controller.event = event
        controller.eventStore = eventStore
        controller.editViewDelegate = self

        
        
        
        controller.modalPresentationStyle = .currentContext
        present(controller, animated: true, completion: nil)
        
        
        isFirstDidAppear = false
    }
}


struct AddEvent: UIViewControllerRepresentable {
    @Binding var scannedEvent: IdentifiableEKEvent?
    
    func makeUIViewController(context: Context) -> AddEventController {
        return AddEventController(scannedEvent: $scannedEvent)
    }
    
    func updateUIViewController(_ uiViewController: AddEventController, context: Context) {
        // We need this to follow the protocol, but don't have to implement it
        // Edit here to update the state of the view controller with information from SwiftUI
    }
}
