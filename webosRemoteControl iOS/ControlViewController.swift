//
//  ControlViewController.swift
//  webosRemoteControl iOS
//
//  Created by Aleksandr Latyntsev on 8/19/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import UIKit

class ControlViewController: UIViewController {
    @IBOutlet weak var volumeSlider: UISlider!
    var input: ServiceProxyModel!
    @IBOutlet weak var muteButton: NSButton!
    var communicator: WebOSCommunicator!

    static func present(on viewController: UIViewController, input: ServiceProxyModel) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let instance = storyboard.instantiateViewController(identifier: "ControlViewController") as! ControlViewController
        instance.modalPresentationStyle = .fullScreen
        instance.input = input
        viewController.present(instance, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        communicator = WebOSCommunicator(uuid: input.uuid, host: input.host)
        communicator.stateChangeHandler = { [weak self] in self?.applyState($0) }
        communicator.connect()
    }

    func applyState(_ state: WebOSCommunicator.State) {
        volumeSlider.value = Float(state.volume) / Float(state.maxVolume)
    }

    @IBAction func volumeValueChanged(_ sender: Any) {
        communicator.setVolume(Int(Float(communicator.state.maxVolume) * volumeSlider.value))
        print(volumeSlider.value)
    }

    @IBAction func tapUp(_ sender: Any) {
        communicator.tapButton(.up)
    }

    @IBAction func tapLeft(_ sender: Any) {
        communicator.tapButton(.left)
    }

    @IBAction func tapRight(_ sender: Any) {
        communicator.tapButton(.right)
    }

    @IBAction func tapDown(_ sender: Any) {
        communicator.tapButton(.down)
    }

    @IBAction func tapEnter(_ sender: Any) {
        communicator.tapButton(.enter)
    }

    @IBAction func tapHome(_ sender: Any) {
        communicator.tapButton(.home)
    }

    @IBAction func tapBack(_ sender: Any) {
        communicator.tapButton(.back)
    }


    var lastTranslation: CGPoint = .zero
    var lastVelocity: CGPoint = .zero
    let throttling = ThrottleRequest(delay: 0.05)
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            lastTranslation = .zero
            lastVelocity = .zero
        }

        let translation = sender.translation(in: nil)
        let velocity = sender.velocity(in: nil)
        let k: CGFloat = 2
        let deltaTranslation = CGPoint(x: translation.x - lastTranslation.x, y: translation.y - lastTranslation.y)
//            let deltaVelocity = CGPoint(x: (velocity.x - lastVelocity.x) * 0.1, y: (velocity.y - lastVelocity.y) * 0.1)

        lastTranslation = translation
        communicator.move(Int(ceil(deltaTranslation.x * k)), y: Int(ceil(deltaTranslation.y * k)))
//            print(deltaTranslation, deltaVelocity)

    }

    @IBAction func tapOnPad(_ sender: Any) {
        communicator.click()
    }
}


protocol TimeBar {
    @IBAction func onClickPlay(_ sender: Any) {
    @IBAction func onClickPause(_ sender: Any) {
    }
    @IBAction func onClickPlay(_ sender: Any) {
    }
    }
    func sendTimeBarRequest(to person: TimeBar)
    @IBAction func onClickPlay(_ sender: Any) {
    }
    func letsGoToTimeBarRequest(_ callback: (Bool) -> Void)
    @IBAction func onClickMute(_ sender: Any) {
    }
}

extension TimeBar {
    func letsGoToTimeBarRequest(_ callback: (Bool) -> Void) {
        callback(true)
    }
    func sendTimeBarRequest(to person: TimeBar) {
        person.letsGoToTimeBarRequest({
            print($0 ? "Cool" : ":(")
        })
    }
}
