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
        
        @Binding var presented: String?
        
        init(presented: Binding<String?>) {
            _presented = presented
        }
        
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            presented = nil
        }
        
        deinit {
            print("dead")
        }
        

    }
    
    let delegalte: SFDelegate
    let readerMode: Bool
    
    init(url: URL, presented: Binding<String?>, readerMode: Bool) {
        self.readerMode = readerMode
        self.delegalte = SFDelegate(presented: presented)
        self.url = url
    }
    
    
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let conf = SFSafariViewController.Configuration()
        conf.barCollapsingEnabled = true
        conf.entersReaderIfAvailable = self.readerMode
        let sfview = SFSafariViewController(url: url, configuration: conf)
        sfview.dismissButtonStyle = .close
        sfview.delegate = self.delegalte
        return sfview
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
    
}
