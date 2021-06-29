//
//  TwitterLoginView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//

import SwiftUI
import SafariServices



final class CustomSafariViewController: UIViewController {
    var url: URL? {
        didSet {
//            guard oldValue != nil else { return }
            configure() // when url changes, reset the safari child view controller
        }
    }
    
    private var safariViewController: SFSafariViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    private func configure() {
        // Remove the previous safari child view controller if not nil
        if let safariViewController = safariViewController {
            safariViewController.willMove(toParent: self)
            safariViewController.view.removeFromSuperview()
            safariViewController.removeFromParent()
            self.safariViewController = nil
        }
        guard let url = url else { return }
        // Create a new safari child view controller with the url
        let conf = SFSafariViewController.Configuration()
        conf.barCollapsingEnabled = true
        conf.entersReaderIfAvailable = true
        let newSafariViewController = SFSafariViewController(url: url, configuration: conf)
        newSafariViewController.dismissButtonStyle = .done
        addChild(newSafariViewController)
        newSafariViewController.view.frame = view.frame
        view.addSubview(newSafariViewController.view)
        newSafariViewController.didMove(toParent: self)
        self.safariViewController = newSafariViewController
    }
}

struct SafariView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CustomSafariViewController
    @Binding var url: URL?
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> CustomSafariViewController {
        let safariController = CustomSafariViewController()
        return safariController
    }
    
    func updateUIViewController(_ safariViewController: CustomSafariViewController,
                                context: UIViewControllerRepresentableContext<SafariView>) {
        safariViewController.url = url // updates our VC's underlying properties
    }
    
}


struct TwitterLoginView: View {
    
    @Binding var url: URL?

    var body: some View {
        if url != nil {
            SafariView(url: $url)
        } else {
            ProgressView()
        }
    }
}


struct TwitterLoginView_Previews: PreviewProvider {
    static var previews: some View {
        TwitterLoginView(url: Binding.constant(URL(string:"")))
    }
}
