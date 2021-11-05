//
//  SpeechRecognizerViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
import UIKit
import SwiftUI

extension UIViewController {
    
    func installChildViewController(_ childController: UIViewController) {
        addChild(childController)
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
}

protocol SpeechRecognizerViewControllerDelegate: AnyObject {
    func speechFeedbackViewModelDidFinish(_ controller: SpeechRecognizerViewController, query: String?)
}

class SpeechRecognizerViewController: UIViewController {
    weak var delegate: SpeechRecognizerViewControllerDelegate?
    private let speechRecognizer = SpeechRecognizer()
    private lazy var blurView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        return effectView
    }()

    deinit {
        print("\(SpeechRecognizerViewController.self) deinit")
    }
    
    private func setupConstraints() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurView)
        view.backgroundColor = .clear
        installSpeechView()
        setupConstraints()
    }
    
    private func installSpeechView() {
        let model = SpeechFeedbackViewModel(speechRecognizer: speechRecognizer)
        model.delegate = self
        let speechView = SpeechFeedbackView(speechModel: model)
        let controller = UIHostingController(rootView: speechView)
        controller.view.backgroundColor = .clear
        installChildViewController(controller)
    }
}

extension SpeechRecognizerViewController: SpeechFeedbackViewModelDelegate {
    
    func speechFeedbackViewModelDidFinish(_ model: SpeechFeedbackViewModel, query: String?) {
        delegate?.speechFeedbackViewModelDidFinish(self, query: query)
    }
}
