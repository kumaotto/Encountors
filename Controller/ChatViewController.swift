//
//  ChatViewController.swift
//  MatchApp1
//
//  Created by kumaotto on 2021/08/06.
//

import UIKit
import MessageKit
import Firebase
import InputBarAccessoryView
import SDWebImage
import Hex


struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController, MessageLabelDelegate, InputBarAccessoryViewDelegate, MessageCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GetAttachProtocol, GetMessageProtocol, ReadUpdateDone {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var menuItems = UIMenu()
    
    var userDataModelArray: UserDataModel?
    var userData = [String:Any]()
    var userDataFromDB: UserDataModel?
    var messages = [Message]()
    
    let loadDBModel = LoadDBModel()
    let sendDBModel = SendDBModel()
    
    var currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: "")
    var otherUser = Sender(senderId: "", displayName: "")
    
    let imageView = UIImageView()
    let blackView = UIView()
    var attachImage: UIImage?
    var attachImageString = String()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMMMHms", options: 0, locale: Locale(identifier: "ja_JP"))
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        return formatter
    }()
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        maintainPositionOnKeyboardFrameChanged = true
        loadDBModel.getMessageProtocol = self
        loadDBModel.getOwnProfileDataProtocol = self
        
        let items = [
            makeButton(image: UIImage(named: "album")!).onTextViewDidChange({ (button, textView) in
                button.isEnabled = textView.text.isEmpty
            })
        ]
        
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.contentInset.top = 12

        currentUser = Sender(senderId: Auth.auth().currentUser!.uid, displayName: (userData["name"] as? String)!)
        
        otherUser = Sender(senderId: (userDataModelArray?.uid)!, displayName: (userDataModelArray?.name)!)
        
        let newMessageInputBar = InputBarAccessoryView()
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.layer.borderWidth = 0.0
        messageInputBar.setLeftStackViewWidthConstant(to: 100, animated: true)
        messageInputBar.setStackViewItems(items, forStack: .left, animated: true)
        messageInputBar.sendButton.setTitle("送信", for: .normal)
        messageInputBar.delegate = self
        
        reloadInputViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = userDataModelArray?.name
        
        loadDBModel.loadMessage(userData: self.userData, partnerData: userDataModelArray!, currentUser: self.currentUser, otherUser: self.otherUser)
        loadDBModel.loadUsersProfileWithoutGender(uid: Auth.auth().currentUser!.uid)
        
        setChatMenu()
        
        sendDBModel.sendUpdateReadMessage(senderID: Auth.auth().currentUser!.uid, toID: (userDataModelArray?.uid)!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func readUpdateDone() {
        self.messagesCollectionView.reloadData()
    }
    
    
    func makeButton(image: UIImage) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = image.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
                
            }.onSelected {
                $0.tintColor = .systemBlue
                self.openCamera()
                
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }
    }
    
    func openCamera() {
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
//            cameraPicker.showsCameraControls = true
            present(cameraPicker, animated: true, completion: nil)
            
        } else {}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let pickedImage = info[.editedImage] as? UIImage
        {
            attachImage = pickedImage
            let sendDBModel = SendDBModel()
            
            sendDBModel.getAttachProtocol = self
            sendDBModel.sendImageData(image: attachImage!, senderID: Auth.auth().currentUser!.uid, toID: (userDataModelArray?.uid)!)
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func getAttachProtocol(attachImageString: String) {
        self.attachImageString = attachImageString
    }
    
    func getImageByURL(url: String) -> UIImage {
        
        let url = URL(string: url)
        
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let error {
            print(error)
        }
        return UIImage()
        
    }
    

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        if self.userDataFromDB?.isSubscribe != true  {
            let alert: UIAlertController = UIAlertController(title: "プランに加入してください", message:  "プラン選択に移りますか？", preferredStyle:  UIAlertController.Style.alert)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default)
            
            let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) -> Void in
                
                let selectPlanVC = self.storyboard?.instantiateViewController(identifier: "selectPlanVC") as! SelectPlanViewController
                selectPlanVC.onModalDismiss = { [weak self] in
                    self?.messagesCollectionView.reloadData()
                }
                self.navigationController?.pushViewController(selectPlanVC, animated: true)
                
            })
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
            
        } else {
            inputBar.sendButton.startAnimating()
            let sendDBModel = SendDBModel()
            
            inputBar.inputTextView.text = ""
            sendDBModel.sendMessage(senderID: Auth.auth().currentUser!.uid, toID: (userDataModelArray?.uid)!, text: text, displayName: userData["name"] as! String, imageURLString: userData["profileImageString"] as! String)
            
            inputBar.sendButton.stopAnimating()
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.imageView.alpha == 1.0 {
            
            UIView.animate(withDuration: 0.2) {
                self.blackView.alpha = 0.0
                self.imageView.alpha = 0.0
                
            } completion: { finish in
                self.blackView.removeFromSuperview()
                self.imageView.removeFromSuperview()
            }
            
        }
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        
        zoomSystem(imageString: messages[indexPath.section].userImagePath, avatorOrNot: true)
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        
        if messages[indexPath.section].messageImageString.isEmpty != true {
            zoomSystem(imageString: messages[indexPath.section].messageImageString, avatorOrNot: false)
        } else { return }
        
    }
    
    func zoomSystem(imageString: String, avatorOrNot: Bool) {
        
        blackView.frame = view.bounds
        blackView.backgroundColor = .darkGray
        blackView.alpha = 0.0
        imageView.frame = CGRect(x: 0, y: view.frame.size.width/2, width: view.frame.size.width, height: view.frame.size.width)
        imageView.isUserInteractionEnabled = true
        imageView.alpha = 0.0
        
        if avatorOrNot == true {
            imageView.layer.cornerRadius = imageView.frame.width/2
        } else {
            imageView.layer.cornerRadius = 20
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 0.9
            self.imageView.alpha = 1.0
        }
        
        imageView.sd_setImage(with: URL(string: imageString), completed: nil)
        view.addSubview(blackView)
        view.addSubview(imageView)
        
    }
    
    func getMessageProtocol(messageArray: [Message]) {
        self.messages = messageArray
        
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
    }
    
}


extension ChatViewController {
    func setChatMenu() {
        let addCat = UIAction(title: "既読アイテムを使う", image: UIImage(systemName: "")) { (action) in
            
            if (self.userDataFromDB?.restOfRead)! > 0 {
                let alert: UIAlertController = UIAlertController(title: "既読アイテム消費", message:  "このユーザーに既読アイテムを消費しますか？", preferredStyle:  UIAlertController.Style.alert)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default)
                
                let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) -> Void in
                    
                    self.sendDBModel.sendReadItemCount(count: -1)
                    
                })
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
                
            }
            else {
                
                let alert: UIAlertController = UIAlertController(title: "既読アイテムが足りません", message:  "アイテム購入に移りますか？", preferredStyle:  UIAlertController.Style.alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default)
                
                let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) -> Void in
                    let storeVC = self.storyboard?.instantiateViewController(identifier: "storeVC") as! PairsStoreViewController
                    self.navigationController?.pushViewController(storeVC, animated: true)
                })
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        let menu = UIMenu(title: "", children: [addCat])
        let menuBarItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), menu: menu)
        navigationItem.rightBarButtonItem = menuBarItem
    }
}


extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        indexPath.section % 2 == 0 ? 10 : 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}


extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
            )
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        
        return NSAttributedString(
            string: dateString,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
        )
    }
    
    // 既読機能 途中
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let isReadOrNot = messages[indexPath.section].isRead
        
        if isReadOrNot == true {
            return NSAttributedString(
                string: "既読",
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)]
            )
        }
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}


extension ChatViewController: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? Util.setChatColor(isOwn: true) : Util.setChatColor(isOwn: false)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.sd_setImage(with: URL(string: messages[indexPath.section].userImagePath), completed: nil)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if case MessageKind.photo(let media) = message.kind {
            imageView.sd_setImage(with: URL(string: messages[indexPath.section].messageImageString), completed: nil)
        } else {}
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
}


extension ChatViewController: GetOwnProfileDataProtocol {
    func getOwnProfileDataProtocol(userDataModel: UserDataModel) {
        self.userDataFromDB = userDataModel
    }
}
