//
//  MessagesViewController.swift
//  ChatAI_iMessage
//
//  Created by Hard Patel on 17/04/23.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController, UITextViewDelegate {
  @IBOutlet weak var bodyText: UITextView!
  @IBOutlet weak var textLengthLabel: UILabel!
  @IBOutlet weak var clearButton: UIButton!
  @IBOutlet weak var askButton: UIButton!
  @IBOutlet weak var parentView: UIView!
  @IBOutlet weak var cnstBottomView: NSLayoutConstraint!
  
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet weak var buttonLabel: UILabel!
  
  var isFullScreen = false
  var isSubscriptionExpired = false
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    
    // Do any additional setup after loading the view.
    bodyText.delegate = self
    clearButton.setTitle("clear".localizedString(), for: .normal)
    loadingIndicator.alpha = 0
    loadingIndicator.tintColor = .white
    
    bodyText.text = "askMeAnything".localizedString();
    bodyText.textColor = UIColor.lightGray
    buttonLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 14.0)
    textLengthLabel.text = "0/2000"
    
    let subscriptinoStatus = isRegisterUser();
    
    if(subscriptinoStatus){
      buttonLabel.text = "ask".localizedString()
    }
    else{
      buttonLabel.text = "subscribe".localizedString()
    }
    UITextView.appearance().tintColor = .black
    self.parentView.endEditing(true)
  }
  
  private func openChatAIApp() {
    guard let appUrl = URL(string: "openchataiapp:") else {
      return
    }
    self.extensionContext?.open(appUrl, completionHandler:nil)
    
  }
  
  @IBAction func askButton(_ sender: UIButton) {
    var subscriptinoStatus = isRegisterUser();
    print("subscriptinoStatus===>",subscriptinoStatus)
    //    let subscriptinoStatus = true;
    //    bodyText.text = String(subscriptinoStatus)
    //    if(subscriptinoStatus){
    //      askButton.titleLabel?.text = "ASK"
    //
    //    }
//    subscriptinoStatus = true;
    
    
    let strAsk = "askMeAnything".localizedString()
    let strValue = self.bodyText.text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    
    if(subscriptinoStatus && (!isSubscriptionExpired)){
      guard strAsk.lowercased() != strValue.lowercased(), strValue.count > 0 else { return }
      loadingIndicator.startAnimating()
      
      loadingIndicator.alpha = 1
      buttonLabel.alpha = 0;
      DispatchQueue.main.async {
        self.serviceCall(self.bodyText.text) { status, response in
          DispatchQueue.main.async { [self] in
            if status,
               let resData = response {
              if resData.responseStatus == 1 {
                
                print("====>",resData)
                self.bodyText.text = "askMeAnything".localizedString();
                self.bodyText.textColor = UIColor.lightGray
                self.textLengthLabel.text = "0/2000"
                self.bodyText.resignFirstResponder()
                
                guard let conversation = activeConversation else { return }
                conversation.insertText(resData.responseText) { error in
                  if let error = error {
                    print("Error inserting text: \(error.localizedDescription)")
                  } else {
                    self.buttonLabel.text = "ask".localizedString()
                    self.requestPresentationStyle(.compact)
                    print("Text inserted successfully!")
                  }
                }
              } else if (resData.responseStatus == 2 || resData.responseStatus == 3) {
                buttonLabel.text = "subscribe".localizedString()
                subscriptinoStatus = false;
                isSubscriptionExpired = true;
              }
            }
            else{
              
            }
            loadingIndicator.stopAnimating()
            loadingIndicator.alpha = 0
            buttonLabel.alpha = 1;
          }
        }
      }
    }else{
      buttonLabel.text = "subscribe".localizedString()
      subscriptinoStatus = false;
      openChatAIApp()
    }
    
  }
  
  @objc private func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
      if isFullScreen {
        print(" keyboardSize ==> \(-(keyboardSize.height))")
        let bottomHeight = UIDevice.isPhoneXSeries() ? 30.0 : 0.0
        self.cnstBottomView.constant = -(keyboardSize.height - bottomHeight)
        //          self.cnstBottomView.constant = -100.0
      }
      self.view.layoutIfNeeded()
    }
  }
  
  @objc private func keyboardWillHide(notification: NSNotification) {
    //    DispatchQueue.main.async {
    self.cnstBottomView.constant = 0
    self.view.layoutIfNeeded()
    //    }
  }
  
  // MARK: - Conversation Handling
  
  override func willBecomeActive(with conversation: MSConversation) {
    requestPresentationStyle(.expanded)
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
      self.bodyText.becomeFirstResponder()
    }
    // Called when the extension is about to move from the inactive to active state.
    // This will happen when the extension is about to present UI.
    
    // Use this method to configure the extension and restore previously stored state.
  }
  
  override func didBecomeActive(with conversation: MSConversation) {
    super.didBecomeActive(with: conversation)
    //          becomeFirstResponder()
  }
  
  //      override var canBecomeFirstResponder: Bool {
  //          return true
  //      }
  //
  //      override var presentationStyle: MSMessagesAppPresentationStyle {
  //          return .expanded
  //      }
  
  
  
  
  override func didResignActive(with conversation: MSConversation) {
    // Called when the extension is about to move from the active to inactive state.
    // This will happen when the user dismisses the extension, changes to a different
    // conversation or quits Messages.
    
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough state information to restore your extension to its current state
    // in case it is terminated later.
  }
  
  override func didReceive(_ message: MSMessage, conversation: MSConversation) {
    // Called when a message arrives that was generated by another instance of this
    // extension on a remote device.
    
    // Use this method to trigger UI updates in response to the message.
  }
  
  override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
    // Called when the user taps the send button.
  }
  
  override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
    // Called when the user deletes the message without sending it.
    
    // Use this to clean up state related to the deleted message.
  }
  
  override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Called before the extension transitions to a new presentation style.
    
    // Use this method to prepare for the change in presentation style.
  }
  
  override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
    // Called after the extension transitions to a new presentation style.
    
    // Use this method to finalize any behaviors associated with the change in presentation style.
    if presentationStyle == .compact {
      self.cnstBottomView.constant = 0
      self.view.layoutIfNeeded()
    }
  }
  
  private func isRegisterUser() -> Bool {
    guard let userDefaults = UserDefaults(suiteName: "group.com.creativai.chataiassistant"),
          let userData = userDefaults.object(forKey: "userData"),
          let strData = userData as? String,
          let userDetail = convertToDictionary(text: strData),
          let subscriptionInfo = userDetail["subscriptionInfo"] as? [String:Any],
          let ai_subscription_active = subscriptionInfo["ai_subscription_active"] as? Int else { return false }
    print("userDetail==>",userDetail);
    return ai_subscription_active > 0 ? true : false
  }
  
  private func getModelType() -> Int {
    guard let userDefaults = UserDefaults(suiteName: "group.com.creativai.chataiassistant"),
          let userData = userDefaults.object(forKey: "modelType"),
          let strData = userData as? String,
          let userDetail = convertToDictionary(text: strData),
          let modelType = userDetail["model_type"] as? Int else { return 1 }
    print("getModelType", userDetail);
    return modelType
  }
  
  private func getUserDeviceID() -> String {
    guard let userDefaults = UserDefaults(suiteName: "group.com.creativai.chataiassistant"),
          let userData = userDefaults.object(forKey: "userData"),
          let strData = userData as? String,
          let userDetail = convertToDictionary(text: strData),
          let device_token = userDetail["device_token"] as? String else { return "" }
    print("===>User Data: ==",strData)
    return device_token
  }
  
  public func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
  
  
  func textViewDidChange(_ textView: UITextView) {
    print("==============>"); //the textView parameter is the textView where text was changed
    textLengthLabel.text = String(textView.text.count)+"/2000"
  }
  
  
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    isFullScreen = true
    requestPresentationStyle(.expanded)
    
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.black
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
      self.bodyText.becomeFirstResponder()
    }
  }
  
  @IBAction func clearButton(_ sender: UIButton) {
    bodyText.text = ""
    bodyText.textColor = UIColor.black
    textLengthLabel.text = "0/2000"
    bodyText.becomeFirstResponder()
  }
  
  
  func textViewDidEndEditing(_ textView: UITextView) {
    isFullScreen = false
    if textView.text.isEmpty {
      textView.text = "askMeAnything".localizedString()
      textLengthLabel.text = "0/2000"
      textView.textColor = UIColor.lightGray
    }
  }
  
  private func serviceCall(_ strInputTex:String, completion:@escaping(_ status:Bool, _ response:ChatAIModel?) -> Void) {
    func callAPI(){
      
       let baseURL = "https://stgapi.chataiassistant.com/api/"
      // let baseURL = "https://api.chataiassistant.com/api/"
      guard let url = URL(string: "\(baseURL)ai/generate-ai-text-keyboard") else{return completion(false, nil)}
      let params = ["device_id": getUserDeviceID(),
                    "is_free": 2,
                    "prompt": strInputTex,
                    "model_type":getModelType()
      ] as [String : Any]
      var request = URLRequest.init(url: url)
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue(LanguageManager.shared.getCurrentLanguageCode(), forHTTPHeaderField: "language")
      request.httpMethod = "POST"
      request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
      
      let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let errorValue = error {
          print("Error ==>", errorValue.localizedDescription)
          return completion(false, nil)
        }
        guard let resData = data else {
          return completion(false, nil)
        }
        
        let decoder = JSONDecoder()
        do{
          let chatAIResponse = try decoder.decode(ChatAIResponseModel.self, from: resData)
          return completion(true, chatAIResponse.chatAIDetail)
        }catch{
          print(error)
          return completion(false, nil)
        }
      }
      task.resume()
    }
    callAPI()
  }
}

struct ChatAIModel: Codable {
  
  var responseStatus: Int = 0
  var responseText: String = ""
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.responseStatus = try container.decodeIfPresent(Int.self, forKey: .responseStatus) ?? 0
    self.responseText = try container.decodeIfPresent(String.self, forKey: .responseText) ?? ""
  }
  
  init() { }
  
  enum CodingKeys: String, CodingKey {
    case responseStatus = "response_status"
    case responseText = "message"
  }
}

struct ChatAIResponseModel: Codable {
  
  var chatAIDetail:ChatAIModel = ChatAIModel()
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let objModel = try? container.decodeIfPresent(ChatAIModel.self, forKey: .chatAIDetail) {
      self.chatAIDetail = objModel
    }
  }
  
  init() { }
  
  enum CodingKeys: String, CodingKey {
    case chatAIDetail = "data"
  }
}
