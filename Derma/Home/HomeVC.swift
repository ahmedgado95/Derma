//
//  ViewController.swift
//  Derma
//
//  Created by Ahmed Gado on 14/02/2025.
//

import UIKit
import GoogleGenerativeAI

class HomeVC: UIViewController {
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    let guidedTour = GuidedTourManager()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isTourCompleted = UserDefaults.standard.bool(forKey: "TourCompleted")
        if !isTourCompleted {
        guidedTour.startTour(
            steps: [imageView,plusButton , historyButton , navigationView],
                messages: ["Derma Image will be displayed here", "Tap here to add your image", "Go to History", "Start your journey! 🚀"]
            )
        navigationController?.setNavigationBarHidden(true, animated: animated)

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func addTapped(_ sender: UIButton) {
        emptyData()
        ImagePickerManager.shared.showActionSheet(vc: self)
        ImagePickerManager.shared.imagePickedBlock = { [weak self](image) in
            self?.imageView.image = image
            self?.useTask(image: image)
        }
    }
      
    func useTask(image : UIImage){
        HomeVC.showUniversalLoadingView(true, loadingText: " Wait Until Finish Analyzing The Image ...")
        Task {
            do {
                try await self.generateContent(image: image )
            } catch {
                print("Error generating content: \(error)")
            }
        }
    }
    
    func generateContent( image : UIImage ) async throws {
        let generativeModel = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: APIKey.default
        )
        let prompt = "Analyze the given image for dermatological conditions. Identify any visible skin issues such as acne, eczema, psoriasis, rosacea, pigmentation, rashes, or other abnormalities. Provide a detailed description of the condition, its severity, and possible causes. Also, suggest potential treatments or skincare recommendations based on the analysis. Ensure the response is medically relevant and formatted clearly for easy interpretation."
        let response = try await generativeModel.generateContent(image, prompt)
        HomeVC.showUniversalLoadingView(false)
        if let text = response.text {
            print(text)
            textView.text = text
            let historyModel = HistoryModel(text: text, image: image)
            let historyDict = historyModel.toDictionary()
            UserDefaults.standard.set(historyDict, forKey: "history")
            UserDefaults.standard.synchronize()
        } else {
            print("No text in response")
        }
    }
    
    func emptyData() {
        textView.text = ""
        imageView.image = nil
    }
    
    @IBAction func historyButtonPressed(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let history = storyBoard.instantiateViewController(withIdentifier: "HistoryVC") as! HistoryVC
        history.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(history, animated:true)
    }
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        addTapped(sender)
    }
}

struct HistoryModel {
    var text: String
    var image: UIImage
}

extension Derma.HistoryModel {
    func toDictionary() -> [String: Any] {
        return [
            "text": self.text,
            "image": self.image.pngData() as Any // Convert UIImage to Data
        ]
    }
}

extension Derma.HistoryModel {
    init?(from dictionary: [String: Any]) {
        guard let text = dictionary["text"] as? String,
              let imageData = dictionary["image"] as? Data,
              let image = UIImage(data: imageData) else {
            return nil
        }
        self.text = text
        self.image = image
    }
}

