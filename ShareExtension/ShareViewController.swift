//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Mia Alexiou on 01/02/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Social
import Core

class ShareViewController: UIViewController, WebLoadingDelegate {
    
    private let urlIdentifier = "public.url"
    private let textIdentifier = "public.plain-text"
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    private var webController: WebViewController?
    private var groupData = GroupData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNavigationButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let urlProvider = getItemProvider(identifier: urlIdentifier) {
            loadUrl(urlProvider: urlProvider)
            return
        }
        if let textProvider = getItemProvider(identifier: textIdentifier) {
            loadText(textProvider: textProvider)
            return
        }
    }
    
    private func getItemProvider(identifier: String) -> NSItemProvider? {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            return nil
        }
        guard let itemProvider = item.attachments?.first as? NSItemProvider else {
            return nil
        }
        if itemProvider.hasItemConformingToTypeIdentifier(identifier) {
            return itemProvider
        }
        return nil
    }
    
    private func loadUrl(urlProvider: NSItemProvider) {
        urlProvider.loadItem(forTypeIdentifier: urlIdentifier, options: nil, completionHandler: { [weak self] (item, error) in
            if let url = item as? URL {
                self?.webController?.load(url: url)
            }
        })
    }
    
    private func loadText(textProvider: NSItemProvider) {
        textProvider.loadItem(forTypeIdentifier: textIdentifier, options: nil, completionHandler: { [weak self] (item, error) in
            if let text = item as? String {
                self?.webController?.load(query: text)
            }
        })
    }
    
    func webpageDidStartLoading() {
    }
    
    func webpageDidFinishLoading() {
        refreshNavigationButtons()
    }
    
    private func refreshNavigationButtons() {
        backButton.isEnabled = webController?.canGoBack ?? false
        forwardButton.isEnabled = webController?.canGoForward ?? false
    }
    
    @IBAction func onRefreshPressed(_ sender: UIBarButtonItem) {
        webController?.reload()
    }
    
    @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
        webController?.goBack()
    }
    
    @IBAction func onForwardPressed(_ sender: UIBarButtonItem) {
        webController?.goForward()
    }
    
    @IBAction func onSaveQuickLink(_ sender: UIBarButtonItem) {
        if let link = webController?.link {
            groupData.addQuickLink(link: link)
            webController?.view.makeToast(UserText.webSaveLinkDone)
        }
    }
    
    @IBAction func onClose(_ sender: UIBarButtonItem) {
        extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    @IBAction func onDeleteEverything(_ sender: UIBarButtonItem) {
        webController?.reset()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WebViewController {
            controller.loadingDelegate = self
            webController = controller
        }
    }
}
