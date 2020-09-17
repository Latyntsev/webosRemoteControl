//
//  MainViewController.swift
//  webosRemoteControl
//
//  Created by Aleksandr Latyntsev on 8/18/20.
//  Copyright © 2020 Latyntsev. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var services = [DiscoverySSDP.Service]()
    let discovery = DiscoverySSDP()
    var storage = SimpleStorage.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let model = storage.mainService else {
            discovery.serviceHandler = { [weak self] in
                self?.services = $0
                self?.tableView.reloadData()
            }
            discovery.start()
            return
        }
        openControlScreen(model: model)
    }

    func openControlScreen(model: ServiceProxyModel) {
        ControlViewController.present(on: self, input: model)
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = services[indexPath.row].locationDetails?.friendlyName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let service = services[indexPath.row]
        let model = ServiceProxyModel(name: service.locationDetails?.friendlyName,
                                      host: service.host,
                                      uuid: service.uuid)
        storage.mainService = model
        openControlScreen(model: model)
    }
}
