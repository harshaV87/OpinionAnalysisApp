//
//  ResponderChain.swift
//  SIGNLOGINMODULE
//
//  Created by Venkata harsha Balla on 7/3/23.
//

import Foundation
import SwiftUI

// Passing values to view heirarchy

// environment key and values
// confirm to env key
struct EventEnvironmentClosure: EnvironmentKey {
    // any values - closure , default implementation
    static var defaultValue: (Any) -> Void = {
        event in
    }
}
// corresponding env value in extension

extension EnvironmentValues {
    // property to get the event in key
     var eventClosure: (Any) -> Void {
        get {self[EventEnvironmentClosure.self]}
         set {self[EventEnvironmentClosure.self] = newValue}
    }
}

// ViewModifier

struct EventHandlerViewModifier: ViewModifier {
    @Environment(\.eventClosure) var eventClosure
    
    let handler: (Any) -> Any?
    
    func body(content: Content) -> some View {
        content.environment(\.eventClosure) {
            if let result = handler($0) {
                eventClosure(result)
            }
        }
    }
}

extension View {
    func eventHandler(handler: @escaping (Any) -> (Any)?) -> some View {
        modifier(EventHandlerViewModifier(handler: handler))
    }
}

