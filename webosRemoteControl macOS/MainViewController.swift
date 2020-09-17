//
//  MainViewController.swift
//  macOS
//
//  Created by Aleksandr Latyntsev on 9/7/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var servicesSegmentControl: NSSegmentedControl!
    var storage = SimpleStorage.shared
    let discovery = DiscoverySSDP()
    var services: [DiscoverySSDP.Service] = []
    var communicator: WebOSCommunicator?
    var controlViewController: ControlViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        discovery.serviceHandler = { [weak self] in
            self?.serviceListUpdated($0)
        }

        discovery.start()
    }

    func serviceListUpdated(_ services: [DiscoverySSDP.Service]) {
        self.services = services
        servicesSegmentControl.segmentCount = services.count

        guard !services.isEmpty else { return }
        for index in 0..<services.count {
            let service = services[index]
            servicesSegmentControl.setLabel(service.locationDetails?.friendlyName ?? "Unknown", forSegment: index)
        }

        if communicator == nil {
            servicesSegmentControl.selectedSegment = 0
            selectService(services[0])
        }
    }

    @IBAction func onSelectSegment(_ sender: NSSegmentedControl) {
        selectService(services[sender.selectedSegment])
    }

    func selectService(_ service: DiscoverySSDP.Service) {
        view.becomeFirstResponder()
        guard communicator?.uuid != service.uuid else { return }
        communicator = .init(uuid: service.uuid, host: service.host, storage: storage)

        controlViewController?.view.isHidden = true
        communicator?.registerStateChangedHandler = { [weak self] in
            switch $0 {
            case .checking, .registration:
                break
            case .registered:
                self?.controlViewController?.view.isHidden = false
            }
        }
        communicator?.connect()
        controlViewController?.communicator = communicator
        discovery.stop()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch segue.identifier {
        case "Control":
            controlViewController = (segue.destinationController as! ControlViewController)
        default:
            break
        }
    }
}
