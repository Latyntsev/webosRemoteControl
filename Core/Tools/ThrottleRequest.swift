//
//  ThrottleRequest.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/20/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Foundation

public class ThrottleRequest {
    let delay: TimeInterval
    init(delay: TimeInterval) {
        self.delay = delay
    }

    private var task: DispatchWorkItem?

    public func request(customDelay: TimeInterval? = nil, closure: @escaping () -> Void) {
        request(closure: closure, afterDelay: customDelay ?? delay)
    }

    public func requestNow(closure: @escaping () -> Void) {
        request(customDelay: 0, closure: closure)
    }

    private func request(closure: @escaping () -> Void, afterDelay delay: TimeInterval) {
        cancel()
        let task = DispatchWorkItem(block: {
            self.task = nil
            closure()
        })
        self.task = task
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: task)
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}
