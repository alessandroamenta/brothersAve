//
//  Extension.swift
//  Trip_App
//
//  Created by Muneeb Zain on 01/08/2022.
//

import UIKit
import AVKit
import Lightbox
import AVFoundation
import CoreLocation
import RappleProgressHUD
//import MBProgressHUD

//MARK: - UILabel
extension UILabel {
    
    func customLabel(text: String, font: String, size: CGFloat, color: UIColor, alignment: NSTextAlignment) {
        self.text = text
        self.font = UIFont(name: font, size: size)
        self.textColor = color
        self.textAlignment = alignment
    }
    
}

//MARK: - UITableViewCell...
extension UITableViewCell {
    
    ///setUpBGView...
    func setUpBGView(){
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        self.selectedBackgroundView = backgroundView
    }
    
    func getTimeAgo(postedDate: Date)-> String {
        
        let currentTimeStamp = Date(), yearsAgo =  currentTimeStamp.years(from: postedDate)
        let monthAgo =  currentTimeStamp.months(from: postedDate), daysAgo =  currentTimeStamp.days(from: postedDate)
        let hoursAgo =  currentTimeStamp.hours(from: postedDate), minutesAgo =  currentTimeStamp.minutes(from: postedDate)
         
        if yearsAgo != 0  { return  (yearsAgo <= 1 ) ? "year ago" : "\(yearsAgo) years ago" }
        else if monthAgo != 0  {  return  (monthAgo <= 1) ? "month ago" : "\(monthAgo) months ago" }
        else if daysAgo != 0  {  return  (daysAgo <= 1) ? "day ago" : "\(daysAgo) days ago" }
        else if hoursAgo != 0  {  return (hoursAgo <= 1) ? "hour ago" : "\(hoursAgo) hours ago" }
        else if minutesAgo != 0  {  return (minutesAgo <= 1) ? "minute ago" : "\(minutesAgo) minutes ago" }
        else { return "Few Second ago" }
    }
    
    func getTimeLeft(postedDate: Date)-> String {
        
        let currentTimeStamp = Date(), yearsAgo =  postedDate.years(from: currentTimeStamp)
        let monthAgo =  postedDate.months(from: currentTimeStamp), daysAgo =  postedDate.days(from: currentTimeStamp)
        let hoursAgo =  postedDate.hours(from: currentTimeStamp), minutesAgo =  postedDate.minutes(from: currentTimeStamp)
         
        if yearsAgo != 0  { return  (yearsAgo <= 1 ) ? "1 year left" : "\(yearsAgo) years left" }
        else if monthAgo != 0  {  return  (monthAgo <= 1) ? "1 month left" : "\(monthAgo) months left" }
        else if daysAgo != 0  {  return  (daysAgo <= 1) ? "1 day left" : "\(daysAgo) days left" }
        else if hoursAgo != 0  {  return (hoursAgo <= 1) ? "1 hour left" : "\(hoursAgo) hours left" }
        else if minutesAgo != 0  {  return (minutesAgo <= 1) ? "1 minute left" : "\(minutesAgo) minutes left" }
        else { return "Expired Now" }
    }
    
//    func showHud(_ message: String) {
//        
//        self.contentView.isUserInteractionEnabled = false
//        
//        let hud = MBProgressHUD.showAdded(to: self.contentView, animated: true)
//        
//        hud.label.text = message
//        hud.isUserInteractionEnabled = false
//        
//        hud.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        
//        hud.contentColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        
//        hud.bezelView.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        
//        hud.bezelView.style = .solidColor
//        
//        self.contentView.bringSubviewToFront(MBProgressHUD())
//        
//    }
//    
//    func hideHUD() {
//        self.contentView.isUserInteractionEnabled = true
//        MBProgressHUD.hide(for: self.contentView, animated: true)
//        
//    }
}

//MARK: - UIImageView
extension UIImageView {
    
    func roundImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

//MARK: - UIView
//extension UIView {
//    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }
//}

extension UINavigationBar {

    func setShadow(hidden: Bool) {
        setValue(hidden, forKey: "hidesShadow")
    }
}

//MARK: - UIViewController
extension UIViewController {
    
    ///openLinkWith...
    func openLinkWith(urlLink: String){
        RappleActivityIndicatorView.stopAnimation()
        if let url = URL(string: urlLink) {
            UIApplication.shared.open(url); RappleActivityIndicatorView.stopAnimation() }
        else { RappleActivityIndicatorView.stopAnimation() }
        
    }
    
    func presentAlertAndGotoThatFunctionWithCancelBtnAction(withTitle title: String, message : String, OKAction: UIAlertAction, secondBtnTitle: String, secondBtnAction: UIAlertAction) {
        var updatedMsg = title
        //if message != "" { updatedMsg.append("\n") }
        let alertController = UIAlertController(title: updatedMsg, message: "\(message)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: secondBtnTitle, style: .default) { action in RappleActivityIndicatorView.stopAnimation() }
        //let alertMainSubviews = alertController.view.subviews.first?.subviews.first?.subviews.first?.subviews
        //let actionView = (alertMainSubviews?[1])! as UIView
        //actionView.addBorder(toEdges: .top, color: .lightGray, thickness: 1)
        alertController.addAction(OKAction)
        alertController.addAction(secondBtnAction)
       // alertController.view.tintColor = Constants.Colors.primaryColor
        //alertController.setBackgroundColor(color: Constants.Colors.backgroundColor)
        //alertController.setTitlet(font: UIFont.systemFont(ofSize: 20), color: Constants.Colors.primaryColor)
        //alertController.setMessage(font: UIFont.systemFont(ofSize: 16), color: Constants.Colors.primaryColor)
        self.present(alertController, animated: true, completion: nil)
    }
    
//    func presentAlertAndGoToViewController(withTitle title: String, message : String, storyboardName: String, idetifier: String) {
//
//        var updatedMsg = title
//        if message != "" { updatedMsg.append("\n") }
//        let alertController = UIAlertController(title: updatedMsg, message: "\(message)", preferredStyle: .alert)
//        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
//            self.pushViewController(storyboard: storyboardName, identifier: idetifier)
//        }
//        let alertMainSubviews = alertController.view.subviews.first?.subviews.first?.subviews.first?.subviews
//        let actionView = (alertMainSubviews?[1])! as UIView
//        actionView.addBorder(toEdges: .top, color: .lightGray, thickness: 1)
//        alertController.addAction(OKAction)
//        //alertController.view.tintColor = Constants.Colors.primaryColor
//        //alertController.setBackgroundColor(color: Constants.Colors.backgroundColor)
//        //alertController.setTitlet(font: UIFont.systemFont(ofSize: 20), color: Constants.Colors.primaryColor)
//        //alertController.setMessage(font: UIFont.systemFont(ofSize: 16), color: Constants.Colors.primaryColor)
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    
    
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func initiateFrom(Storybaord _storybaord: Storyboard) -> Self {
        return _storybaord.viewController(Class: self)
    }

    
    @discardableResult func popTo(ViewController _viewController: UIViewController.Type) -> Bool {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: _viewController.self) {
                _ =  self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        return false
    }
    
    func ZoomImageWithUrl(url: String){
        let images = [
            LightboxImage(imageURL: URL(string: url)!)
        ]
        let controller = LightboxController(images: images)
        controller.modalPresentationStyle = .fullScreen
        controller.dynamicBackground = true
        present(controller, animated: true, completion: nil)
    }
    
    func presentAlertAndGotoThatFunctionWithCancelBtn(withTitle title: String, message : String, OKAction: UIAlertAction, secondBtnTitle: String) {
        let alertController = UIAlertController(title: title, message: "\(message)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: secondBtnTitle, style: .default) { action in
        }
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func ConfigureCell(tableView:UITableView?, collectionView:UICollectionView?, nibName: String, reuseIdentifier: String, cellType: type){
        switch cellType {
        case .tblView:
            tableView?.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        default:
            collectionView?.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        }
    }
    
    func pushViewController(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentAlert(withTitle title: String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in}
        alertController.addAction(OKAction)
        //alertController.view.tintColor = #colorLiteral(red: 0.662745098, green: 0.3019607843, blue: 0.3137254902, alpha: 1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentOnRoot(`with` viewController : UIViewController){
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(navigationController, animated: false, completion: nil)
    }
    
//    func showHud(_ message: String) {
//        
//        self.view.isUserInteractionEnabled = false
//        
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        
//        hud.label.text = message
//        hud.isUserInteractionEnabled = false
//        
//        hud.backgroundColor = UIColor.black.withAlphaComponent(0.2)
//        
//        hud.contentColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//        
//        hud.bezelView.color = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        
//        hud.bezelView.style = .solidColor
//        
//        self.view.bringSubviewToFront(MBProgressHUD())
//        
//    }
//    
//    func hideHUD() {
//        self.view.isUserInteractionEnabled = true
//        MBProgressHUD.hide(for: self.view, animated: true)
//        
//    }
}

//MARK: - String...
extension String {
    ///grouping...
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
       let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
       return String(cleanedUpCopy.enumerated().map() { $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element] }
       .joined().dropFirst())
    }
}

//MARK: - UITextField
extension UITextField {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self.text)
    }
    
    func isEmptyTextField() -> Bool {
        if self.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" { return true } else { return false}
    }
    
    func setText(to newText: String, preservingCursor: Bool) {
        if preservingCursor {
            let cursorPosition = offset(from: beginningOfDocument, to: selectedTextRange!.start) + newText.count - (text?.count ?? 0)
            text = newText
            if let newPosition = self.position(from: beginningOfDocument, offset: cursorPosition) {
                selectedTextRange = textRange(from: newPosition, to: newPosition)
            }
        } else { text = newText }
    }
    
    func isValidPassword() -> Bool {
        // Minimum 8 and Maximum 20 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,20}"
        let passwordPred =  NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPred.evaluate(with: self.text)
    }
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        // iOS 14 and above
        if #available(iOS 14, *) {// Added condition for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        self.inputView = datePicker //3
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
    
}

//MARK: - UILabel
extension UILabel {
    
    func customLabel(text: String, font: String, size: CGFloat) {
        self.text = text
        self.font = UIFont(name: font, size: size)
    }
    func removeSoonLineBreakFromLabel() {

         if #available(iOS 14.0, *) { self.lineBreakStrategy = [] }

         else {

             self.lineBreakMode = .byWordWrapping

             //self.lineBreakStrategy = NSParagraphStyle.LineBreakStrategy.pushOut

             //self.lineBreakStrategy = .init()

         }

     }
}

//MARK: - NSMutableAttributedString
extension NSMutableAttributedString {
    
    func setColorForText(textToFind: String,  textColor: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
        }
    }
    
    func setFontForText(textToFind: String, font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
    }
    
    func setUnderlinetext(textToFind: String, underlineColor: UIColor) {
        let range = self.mutableString.range(of: textToFind)
        if range.location != NSNotFound {
            addAttributes([.underlineColor:  underlineColor,
                           .underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
        }
    }
    
}

//MARK: - String
extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func toDouble() -> Double {
        let double = Double(self)
        return double ?? 0
    }
}

// MARK: - UIViewController...
extension UIViewController {
    
    func presentAvVideoPlayerNow(controller: UIViewController, videoURL: URL){
        let player = AVPlayer(url: videoURL)
        let vc = AVPlayerViewController()
        vc.player = player
        controller.present(vc, animated: true) { vc.player?.play() }
    }
    
    ///popViewController...
    func popViewController(animated: Bool = true){ self.navigationController?.popViewController(animated: animated) }
    
    ///dismissViewController...
    func dismissViewController(){ self.dismiss(animated: true) }
    
    ///popToRootViewController...
    func popToRootViewController(){ self.navigationController?.popToRootViewController(animated: true) }
    
    ///pushViewController...
    func pushViewController(storyboard: String ,identifier: String, hidesBottomBarWhenPushed : Bool = false) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setNewRootViewController(storyboard: String ,identifier: String, hidesBottomBarWhenPushed: Bool = false) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        controller.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
    }
    
    ///pushAndInitiateViewController...
    func pushAndInitiateViewController(storyboardName: String){
        let controller = UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
        self.navigationController?.pushViewController(controller!, animated: true)
    }
    
    ///present...
    func present(storyboard: String ,identifier: String) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        self.present(controller, animated: true)
    }
    
    ///pushViewControllerWithNavigationController...
    func pushViewControllerWithNavigationController(storyboard: String ,identifier: String){
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        let navigationController = UINavigationController(rootViewController: controller)
        self.navigationController?.pushViewController(navigationController, animated: true)
    }
        
    ///presentAlert...
    func presentThemeAlert(withTitle title: String, message : String) {
        
        var updatedMsg = title
        if message != "" { updatedMsg.append("\n") }
        let alertController = UIAlertController(title: updatedMsg, message: "\(message)", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in}
        let alertMainSubviews = alertController.view.subviews.first?.subviews.first?.subviews.first?.subviews
        let actionView = (alertMainSubviews?[1])! as UIView
        actionView.addBorder(toEdges: .top, color: .lightGray, thickness: 1)
        alertController.addAction(OKAction)
        //alertController.view.tintColor = Constants.Colors.primaryColor
        //alertController.setBackgroundColor(color: Constants.Colors.backgroundColor)
        //alertController.setTitlet(font: UIFont.boldSystemFont(ofSize: 20), color: Constants.Colors.primaryColor)
        //alertController.setMessage(font: UIFont.systemFont(ofSize: 16), color: Constants.Colors.primaryColor)
         
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///presentAlertAndGoToViewController...
    
    func presentAlertAndGoToViewController(withTitle title: String, message : String, storyboardName: String, idetifier: String) {

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            self.pushViewController(storyboard: storyboardName, identifier: idetifier)
        }
        alertController.addAction(OKAction)
        alertController.view.tintColor = .black
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///presentAlertAndBackToPreviousView...
    func presentAlertAndBackToPreviousView(withTitle title: String, message : String, controller: UIViewController) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            controller.navigationController?.popViewController(animated: true)
        }
        alertController.view.tintColor = .black
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert(){
        self.presentThemeAlert(withTitle: "Error", message: "please try again")
    }
    
    ///presentAlertAndBackToRootView...
    func presentAlertAndBackToRootView(withTitle title: String, message : String, controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            controller.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(OKAction)
        alertController.view.tintColor = .black
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///getSpecificControllerForNavigationStack...
    func getSpecificControllerForNavigationStack(wantedController: Swift.AnyClass, fromNavigationController: UINavigationController)-> UIViewController? {
        for controller in self.navigationController!.viewControllers as Array { if controller.isKind(of: wantedController) { return controller } }
        return nil
    }
    
    ///getSpecificControllerForNavigationStackk...
    func getSpecificControllerForNavigationStackk(wantedController: Swift.AnyClass, fromNavigationController: UINavigationController)-> UIViewController? {
        
        for controller in self.navigationController!.viewControllers as Array {  if controller.isKind(of: wantedController) { return controller } }
        return nil
    }
    
    ///removeSpecificControllerForNavigationStack...
    func removeSpecificControllerForNavigationStack(wantedToDeleteThatController: Swift.AnyClass, fromNavigationController: UINavigationController) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: wantedToDeleteThatController) {
                self.navigationController?.viewControllers.removeAll(where: { (VC) -> Bool in
                    if VC == controller{ return true } else { return false }
                })
            }
        }
    }
    
    //    ///showHud...
    //    func showHud(_ message: String) {
    //        self.view.isUserInteractionEnabled = false
    //        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
    //        hud.label.text = message; hud.isUserInteractionEnabled = false
    //        hud.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    //        hud.contentColor = Constants.Colors.mainHeadingTextColor
    //        self.view.bringSubviewToFront(MBProgressHUD())
    //    }
    //
    //    ///hideHUD...
    //    func hideHUD() { self.view.isUserInteractionEnabled = true; MBProgressHUD.hide(for: self.view, animated: true) }
    
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
            return window
        }
        
        //    guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return self.window
    }
    
    ///presentAlertAndDismissToPreviousView...
    func presentAlertAndDismissToPreviousView(withTitle title: String, message : String, controller: UIViewController) {
        
        var updatedMsg = title
        if message != "" { updatedMsg.append("\n") }
        let alertController = UIAlertController(title: updatedMsg, message: "\(message)", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
            //controller.dismissViewController()
            self.popViewController()
        }
        let alertMainSubviews = alertController.view.subviews.first?.subviews.first?.subviews.first?.subviews
        let actionView = (alertMainSubviews?[1])! as UIView
        actionView.addBorder(toEdges: .top, color: .lightGray, thickness: 1)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///popToPreviousSpecificController...
    func popToPreviousSpecificController(popController: AnyClass){
        guard let popController = self.getSpecificControllerForNavigationStack(wantedController: popController, fromNavigationController: self.navigationController!)
        else { self.navigationController?.popToRootViewController(animated: true); return }
        self.navigationController?.popToViewController(popController, animated: true)
    }
    
    ///getPreviousViewController...
    func getPreviousViewController() -> UIViewController  {
        let i = self.navigationController?.viewControllers.firstIndex(of: self)
        guard let controller = navigationController?.viewControllers[i!-1] else {return UIViewController()}
        return controller as UIViewController
    }
    
    ///getSuperParentViewController...
    func getSuperParentViewController() -> UIViewController { return getPreviousViewController().getPreviousViewController() }
    
    ///getPreviousViewControllerNameIntoString...
    //func getPreviousViewControllerNameIntoString(_ obj: Any) -> String { return String(describing: type(of: obj)) }
    
    ///addChildViewControllerWithView...
    func addChildViewControllerWithView(_ childViewController: UIViewController, toView view: UIView? = nil) {
        let view: UIView = view ?? self.view
        childViewController.removeFromParent()
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        childViewController.didMove(toParent: self)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childViewController.view)
        view.addConstraints([
            NSLayoutConstraint(item: childViewController.view!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: childViewController.view!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: childViewController.view!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: childViewController.view!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        view.layoutIfNeeded()
    }
    
    ///removeChildViewController...
    func removeChildViewController(_ childViewController: UIViewController) {
        childViewController.removeFromParent(); childViewController.willMove(toParent: nil)
        childViewController.removeFromParent(); childViewController.didMove(toParent: nil)
        childViewController.view.removeFromSuperview(); view.layoutIfNeeded()
    }
}

//MARK: - Giving Inner shadow to uiview
extension UIView {
    
    
    func addTopShadow(shadowColor : UIColor, shadowOpacity : Float,shadowRadius : CGFloat,offset:CGSize){
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowRadius = shadowRadius
        self.clipsToBounds = false
    }
    
    
    func addShadow(to edges: [UIRectEdge], radius: CGFloat = 6.0, opacity: Float = 0.5, color: CGColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.25).cgColor) {
        
        let fromColor = color
        let toColor = UIColor.white.cgColor
        let viewFrame = self.frame
        for edge in edges {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [fromColor, toColor]
            gradientLayer.opacity = opacity
            
            switch edge {
            case .top:
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: radius)
            case .bottom:
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer.frame = CGRect(x: 0.0, y: viewFrame.height - radius, width: viewFrame.width, height: radius)
            case .left:
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: radius, height: viewFrame.height)
            case .right:
                gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.frame = CGRect(x: viewFrame.width - radius, y: 0.0, width: radius, height: viewFrame.height)
            default:
                break
            }
            self.layer.addSublayer(gradientLayer)
        }
    }
    
    func addDashedBorder() {
        let color = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [3,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    ///make custome round corners
    func roundCorners(corners:CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
}

// MARK: - NSMutableAttributedString...
extension NSMutableAttributedString {
    func addSpacer(font: UIFont){
        self.append(NSAttributedString(string: " Spacer \n", attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor: UIColor.clear]))
    }
}

// MARK: - Double...
extension Double {
    func roundTospecificDigits(digit: Int)-> String {
        return String(format: "%.\(digit)f", self)
    }
}

// MARK: - Double...
extension UIButton {
    
    /// setTitle...
    func setTitle(title: String, state: UIControl.State = .normal){
        self.setTitle(title, for: state)
    }
    
    func setImage(with imageName: String, state: UIControl.State = .normal){
        self.setTitle(title: "")
        self.setImage(UIImage(named: imageName), for: state)
    }
    
    func setImageWithSystemName(with systemName: String, state: UIControl.State = .normal){
        self.setImage(UIImage(systemName: systemName), for: state)
    }
}



///UITextField...
extension UITextView {
    func isEmptyTextView() -> Bool {
        if self.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" { return true } else { return false}
    }
}

///TextField...
@IBDesignable

class customSwitch: UISwitch {
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}

class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX ))
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX ))
    }
}

class TextFieldWithImage: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX + 40))
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX + 40))
    }
}

//MARK:- CAGradientLayer
extension CAGradientLayer {
    
    func setGradientLayer(color1: UIColor, color2: UIColor, for containerView: UIView, cornerRadius: CGFloat, startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)) {
        self.colors = [color1.cgColor, color2.cgColor]; self.startPoint = startPoint
        self.endPoint = endPoint; self.frame = containerView.frame; self.cornerRadius = cornerRadius
    }
    
    func setGradientLayerWithLocation(color1: UIColor, color2: UIColor, with frame: CGRect, cornerRadius: CGFloat) {
        self.frame = frame; self.colors = [color1.cgColor, color2.cgColor]; self.cornerRadius = cornerRadius; self.locations = [0.5, 1.0]
    }
}


///GradientView...
class GradientView: UIView {
    
    // MARK: - View Init Methods...
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Function...
    private func setupView() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        guard let theLayer = self.layer as? CAGradientLayer else { return }
        theLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        theLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        theLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
        //theLayer.cornerRadius = 9
        theLayer.frame = self.bounds
    }
    
    override class var layerClass: AnyClass { return CAGradientLayer.self }
}


extension SceneDelegate {
    func pushViewController(storyboard: String ,identifier: String, hidesBottomBarWhenPushed: Bool = true) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        controller.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        //self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setNewRootViewController(storyboard: String ,identifier: String, hidesBottomBarWhenPushed: Bool = true) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        controller.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
    }
}

extension UIImage {
    
    //MARK: - Setting image quality
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImageView {
    
    ///setUpImageView...
    func setUpImageView(image: String?, mode: UIView.ContentMode)
    {  self.contentMode = mode; if let imageName = image {self.image = UIImage(named: imageName)} }
    
    ///setImage...
    func setImage(image: String?){ if let imageName = image {self.image = UIImage(named: imageName)} }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode:UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                print("Error downloading is: \(error?.localizedDescription)")
                return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension UITextView {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What do you want to talk about?"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

///GradientView...
//class GradientView: UIView {
//
//    // MARK: - View Init Methods...
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//
//    // MARK: - Function...
//    private func setupView() {
//        autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        guard let theLayer = self.layer as? CAGradientLayer else { return }
//        theLayer.colors = [UIColor.black.withAlphaComponent(1).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
//        theLayer.startPoint = CGPoint(x: 0.0, y: 0.2)
//        theLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
//        theLayer.cornerRadius = 9
//        theLayer.frame = self.bounds
//    }
//
//    override class var layerClass: AnyClass { return CAGradientLayer.self }
//}

extension UIView {
    @discardableResult
    func addLineDashedStroke(pattern: [NSNumber]?, radius: CGFloat, color: CGColor) -> CALayer {
        let borderLayer = CAShapeLayer()

        borderLayer.strokeColor = color
        borderLayer.lineDashPattern = pattern
        borderLayer.frame = bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath

        layer.addSublayer(borderLayer)
        return borderLayer
    }
}

extension UISwitch {

    func set(width: CGFloat, height: CGFloat) {

        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51

        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth

        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}


extension String {
    func isValidEmail(_ sender:String!) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: sender)
    }
}
extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UIImageView {
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
extension UIView {
    
    
   func addBorder(toEdges edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
       
       func addBorder(toEdge edges: UIRectEdge, color: UIColor, thickness: CGFloat) {
           let border = CALayer()
           border.backgroundColor = color.cgColor
           
           switch edges {
           case .top:
               border.frame = CGRect(x: 0, y: 0, width: frame.width * 3 , height: thickness)
           case .bottom:
               border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
           case .left:
               border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
           case .right:
               border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
           default:
               break
           }
           
           layer.addSublayer(border)
       }
       
       if edges.contains(.top) || edges.contains(.all) {
           addBorder(toEdge: .top, color: color, thickness: thickness)
       }
       
       if edges.contains(.bottom) || edges.contains(.all) {
           addBorder(toEdge: .bottom, color: color, thickness: thickness)
       }
       
       if edges.contains(.left) || edges.contains(.all) {
           addBorder(toEdge: .left, color: color, thickness: thickness)
       }
       
       if edges.contains(.right) || edges.contains(.all) {
           addBorder(toEdge: .right, color: color, thickness: thickness)
       }
   }
    
    func roundCorner(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension URL {
    func generateThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            // Swift 5.3
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)

            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)

            return nil
        }
    }
}


//extension UIViewController {
//
//    func ZoomImageWithUrl(url: String){
//        let images = [
//            LightboxImage(imageURL: URL(string: url)!)
//        ]
//        let controller = LightboxController(images: images)
//        controller.modalPresentationStyle = .fullScreen
//        controller.dynamicBackground = true
//        present(controller, animated: true, completion: nil)
//    }
//
//}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}

extension UIActivityIndicatorView {
    func scaleIndicator(factor: CGFloat) {
        transform = CGAffineTransform(scaleX: factor, y: factor)
    }
}

fileprivate var aView : UIView?

extension UIViewController {
    
    func showLoader(){
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = UIColor.white
        ai.scaleIndicator(factor: 1.5)
        ai.center = aView!.center
        ai.startAnimating()
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
    
    func hideLoader(){
        
            aView?.removeFromSuperview()
            aView = nil
    }
    
}


extension String {
    func trimWhiteSpace() -> String {
        let string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return string
    }
}

extension UIScrollView {

    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension NSDate {

    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false

        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }

        //Return Result
        return isGreater
    }

    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false

        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }

        //Return Result
        return isLess
    }

    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false

        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }

        //Return Result
        return isEqualTo
    }

    func addDays(daysToAdd: Int) -> NSDate {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: NSDate = self.addingTimeInterval(secondsInDays)

        //Return Result
        return dateWithDaysAdded
    }

    func addHours(hoursToAdd: Int) -> NSDate {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: NSDate = self.addingTimeInterval(secondsInHours)

        //Return Result
        return dateWithHoursAdded
    }
}

extension String {
    func split(regex pattern: String) -> [String] {

        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }

        let nsString = self as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.components(separatedBy: stop)
    }
}

