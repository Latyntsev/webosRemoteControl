//
//  ControlViewController.swift
//  macOS
//
//  Created by Aleksandr Latyntsev on 9/7/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Cocoa
import HotKey

class ControlViewController: NSViewController {
    weak var communicator: WebOSCommunicator? {
        didSet {
            oldValue?.stateChangeHandler = nil
            communicator?.stateChangeHandler = { [weak self] in self?.stateUpdated($0) }
        }
    }
    @IBOutlet weak var muteButton: NSButton!
    var hotKeys: [HotKey] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeKeyboardEvents()
    }

    private func stateUpdated(_ state: WebOSCommunicator.State) {
        let volume = state.mute ? "🔇" : "\(state.volume)"
        muteButton.title = volume
    }

    func subscribeKeyboardEvents() {
        Keyboard.shared.subscribe(keyCode: 13, owner: self, handler: { $0.onClickUp() }) // w
        Keyboard.shared.subscribe(keyCode: 1, owner: self, handler: { $0.onClickDown() }) // s
        Keyboard.shared.subscribe(keyCode: 0, owner: self, handler: { $0.onClickLeft() }) // a
        Keyboard.shared.subscribe(keyCode: 2, owner: self, handler: { $0.onClickRight() }) // d
        Keyboard.shared.subscribe(keyCode: 49, owner: self, handler: { $0.onClickOk() }) // space
        Keyboard.shared.subscribe(keyCode: 14, owner: self, handler: { $0.onClickHome() }) //e
        Keyboard.shared.subscribe(keyCode: 53, owner: self, handler: { $0.onClickBack() }) // esc
        Keyboard.shared.subscribe(keyCode: 126, owner: self, handler: { $0.onClickVolumeUp() }) // up arrow
        Keyboard.shared.subscribe(keyCode: 125, owner: self, handler: { $0.onClickVolumeDown() }) // down arrow
        Keyboard.shared.subscribe(keyCode: 18, owner: self, handler: { $0.onClickPlay() }) // 1
        Keyboard.shared.subscribe(keyCode: 19, owner: self, handler: { $0.onClickPause() }) // 2
        Keyboard.shared.subscribe(keyCode: 46, owner: self, handler: { $0.onClickMute() }) // m

        hotKeys.append(.init(key: .upArrow,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickUp() }))

        hotKeys.append(.init(key: .downArrow,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickDown() }))

        hotKeys.append(.init(key: .leftArrow,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickLeft() }))

        hotKeys.append(.init(key: .rightArrow,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickRight() }))

        hotKeys.append(.init(key: .space,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickOk() }))

        hotKeys.append(.init(key: .slash,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickHome() }))

        hotKeys.append(.init(key: .backslash,
                             modifiers: [.function, .control, .option],
                             keyDownHandler: { [weak self] in self?.onClickBack() }))
    }

    @IBAction func onClickHome(_ sender: Any? = nil) {
        communicator?.tapButton(.home)
    }

    @IBAction func onClickBack(_ sender: Any? = nil) {
        communicator?.tapButton(.back)
    }

    @IBAction func onClickOk(_ sender: Any? = nil) {
        communicator?.tapButton(.enter)
    }

    @IBAction func onClickUp(_ sender: Any? = nil) {
        communicator?.tapButton(.up)
    }

    @IBAction func onClickDown(_ sender: Any? = nil) {
        communicator?.tapButton(.down)
    }

    @IBAction func onClickLeft(_ sender: Any? = nil) {
        communicator?.tapButton(.left)
    }

    @IBAction func onClickRight(_ sender: Any? = nil) {
        communicator?.tapButton(.right)
    }

    @IBAction func onClickVolumeUp(_ sender: Any? = nil) {
        communicator?.volumeUp()
    }

    @IBAction func onClickVolumeDown(_ sender: Any? = nil) {
        communicator?.volumeDown()
    }

    @IBAction func onClickPlay(_ sender: Any? = nil) {
        communicator?.play()
    }

    @IBAction func onClickPause(_ sender: Any? = nil) {
        communicator?.pause()
    }

    @IBAction func onClickMute(_ sender: Any? = nil) {
        guard let mute = communicator?.state.mute else { return }
        communicator?.setMute(!mute)
    }
}
