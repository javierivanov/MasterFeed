//
//  SafariWebView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 02-07-21.
//

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    
    var url: URL
    class SFDelegate: NSObject, SFSafariViewControllerDelegate {
        
        @Binding var presented: Bool
        
        init(presented ispresented: Binding<Bool>) {
            _presented = ispresented
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            presented.toggle()
        }
    }
    
    let delegalte: SFDelegate
    let readerMode: Bool
    
    init(url: URL, presented: Binding<Bool>, readerMode: Bool) {
        self.readerMode = readerMode
        self.delegalte = SFDelegate(presented: presented)
        self.url = url
    }
    
    
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let conf = SFSafariViewController.Configuration()
        conf.barCollapsingEnabled = true
        conf.entersReaderIfAvailable = self.readerMode
        let sfview = SFSafariViewController(url: url, configuration: conf)
        sfview.dismissButtonStyle = .done
        sfview.delegate = self.delegalte
        return sfview
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
    
}
