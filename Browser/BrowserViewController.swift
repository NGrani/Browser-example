//
//  BrowserViewController.swift
//  Browser
//
//  Created by Георгий Маркарян on 11.05.2022.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController {

    private var nc = NotificationCenter.default

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white

        return $0
    }(UIView())

    private lazy var webBrowser: WKWebView = {
        let webBrowser = WKWebView()
        webBrowser.translatesAutoresizingMaskIntoConstraints = false
        webBrowser.navigationDelegate = self
        return webBrowser
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints =  false
        textField.layer.cornerRadius = 12
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.textAlignment = .left
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.font = UIFont(name:"HelveticaNeue", size: 15.0)
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.placeholder = "Введите адрес веб-сайта"
        textField.delegate = self

        return textField
    }()

    private var backButton: UIButton = {
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: UIControl.State.normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return backButton
    }()

    private var forwardButton: UIButton = {
        let forwardButton = UIButton()
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.setImage(UIImage(systemName: "chevron.right.circle.fill"), for: UIControl.State.normal)
        forwardButton.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
        return forwardButton
    }()

    private var reloadButton: UIButton = {
        let reloadButton = UIButton()
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.setBackgroundImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        reloadButton.addTarget(self, action: #selector(reloadAction), for: .touchUpInside)
        return reloadButton
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 0.5
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layout()
        loadWebContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        nc.addObserver(self, selector: #selector(keyboardShow), name:  UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardShow(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            view.backgroundColor = UIColor("#d1d4da")
            contentView.backgroundColor = UIColor("#d1d4da")
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc private func keyboardHide(){
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }

    @objc private func backAction(){
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.backButton.alpha = 0.5
        }) { (completed) in
            UIView.animate(withDuration: 0.5,
                           animations: {
                self.backButton.alpha = 1
            })
        }
        if webBrowser.canGoBack{
            webBrowser.goBack()
        }

    }

    @objc private func reloadAction(){
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.reloadButton.alpha = 0.5
        }) { (completed) in
            UIView.animate(withDuration: 0.5,
                           animations: {
                self.reloadButton.alpha = 1
            })
        }
        guard let currentPage = textField.text else { return  }
        guard let url = URL(string: currentPage) else { return  }
        let request = URLRequest(url: url)
        webBrowser.load(request)
        webBrowser.allowsBackForwardNavigationGestures = true

    }

    @objc private func forwardAction(){
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.forwardButton.alpha = 0.5
        }) { (completed) in
            UIView.animate(withDuration: 0.5,
                           animations: {
                self.forwardButton.alpha = 1
            })
        }
        if webBrowser.canGoForward{
            webBrowser.goForward()
        }

    }

    private func loadWebContent(){
        let homePage = "https://github.com/NGrani"
        guard let url = URL(string: homePage) else { return }
        let request = URLRequest(url: url)
        webBrowser.load(request)
        webBrowser.allowsBackForwardNavigationGestures = true
    }
    
    private func layout(){
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [backButton, reloadButton, forwardButton].forEach {stackView.addArrangedSubview($0)}

        [textField, stackView, webBrowser ].forEach {contentView.addSubview($0)}

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            webBrowser.topAnchor.constraint(equalTo: contentView.topAnchor),
            webBrowser.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            webBrowser.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -5),
            webBrowser.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            webBrowser.heightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.heightAnchor, constant: -60),

            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5),
            textField.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 2),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 50),

            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.widthAnchor.constraint(equalToConstant: 145),
            stackView.heightAnchor.constraint(equalToConstant: 49),

        ])
    }
}

//oginButton.backgroundColor = UIColor("#0044cc")

// MARK: - UITextFieldDelegate
extension BrowserViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let urlString = "https:\(textField.text!)"
        guard let url = URL(string: urlString.lowercased()) else { return false }
        let request = URLRequest(url: url)
        webBrowser.load(request)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WKNavigationDelegate
extension BrowserViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        textField.text = webView.url?.absoluteString
    }


}

// MARK: - HexToUIColor
extension UIColor {

    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if cString.count != 6 {
            self.init("ff0000") // return red color for wrong hex input
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }

}
