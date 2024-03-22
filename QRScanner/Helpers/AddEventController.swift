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

struct EventEditView: UIViewControllerRepresentable {
    @Binding var scannedEvent: IdentifiableEKEvent?
    @Environment(\.presentationMode) var presentationMode
    @Binding var showAlert: Bool
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EventEditView

        init(_ parent: EventEditView) {
            self.parent = parent
        }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.presentationMode.wrappedValue.dismiss()
            if action == .saved {
                parent.showAlert = true
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let eventStore = EKEventStore()
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
        controller.editViewDelegate = context.coordinator

        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // We need this to follow the protocol, but don't have to implement it
        // Edit here to update the state of the view controller with information from SwiftUI
    }
}
