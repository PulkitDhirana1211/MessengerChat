//
//  ChatViewController.swift
//  MessengerChatApp
//
//  Created by Pulkit Dhirana on 17/10/23.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    
    private let selfSendor = Sender(
        photoURL: "",
        senderId: "1",
        displayName: "Joe Smith")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        messages.append(Message(sender: selfSendor,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello Message")))
        messages.append(Message(sender: selfSendor,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello Message2")))

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }

}

//MARK: - Messages Delegate Methods

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType {
        return selfSendor
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
