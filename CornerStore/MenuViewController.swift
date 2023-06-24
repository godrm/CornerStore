//
//  ViewController.swift
//  CornerStore
//
//  Created by JK on 2023/04/20.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let menuItems = [
        [ "title" : "진라면 컵라면", "price" : "800원", "image" : "진라면소컵" ],
        [ "title" : "바나나맛 우유", "price" : "1,000원", "image" : "바나나우유" ],
        [ "title" : "오! 감자 그라탕", "price" : "800원", "image" : "오감자그라탕" ],
        [ "title" : "서울우유 초콜릿", "price" : "800원", "image" : "서울우유" ]
    ]
    let synthesizer = AVSpeechSynthesizer()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuCell
        let item = menuItems[indexPath.row]
        cell.itemImage.image = UIImage(named: item["image"]!)
        cell.itemTitle.text = item["title"]!
        cell.itemPrice.text = item["price"]!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MenuCell.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]
        
        speakSomething(ment: item["title"]! + item["price"]!)
    }
    
    func speakSomething(ment: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: ment)
        utterance.voice = AVSpeechSynthesisVoice.init(language: "ko_KR")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

