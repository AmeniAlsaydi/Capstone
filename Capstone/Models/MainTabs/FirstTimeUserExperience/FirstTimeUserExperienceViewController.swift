//
//  FirstTimeUserExperienceViewController.swift
//  Capstone
//
//  Created by Gregory Keeley on 6/3/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit

class FirstTimeUserExperienceViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //    private var screenshots = ["screenshot1", "screenshot2", "screenshot3", "screenshot4"]
    private var screenshots = ["CareerViewlogo"]
    //MARK:- ViewLifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        updateUserFirstTimeLogin()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }
    //MARK:- Private funcs
    private func configureView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "ScreenshotCollectionViewCellXib", bundle: nil), forCellWithReuseIdentifier: "screenshotCell")
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = screenshots.count
    }
    private func updateUserFirstTimeLogin() {
        DatabaseService.shared.updateUserFirstTimeLogin(firstTimeLogin: false) { (result) in
            switch result {
            case.failure(let error):
                print("error updating user first time login: \(error.localizedDescription)")
            case .success:
                print("User first time login update successfully")
            }
        }
    }
    //MARK:- IBAction funs
    @IBAction func skipForNowButtonPressed(_ sender: UIButton) {
        UIViewController.showMainAppView()
    }
}
//MARK:- Extensions
extension FirstTimeUserExperienceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = collectionView.frame.width
        let maxHeight: CGFloat = collectionView.frame.height
        return CGSize(width: maxWidth, height: maxHeight)
    }
}
extension FirstTimeUserExperienceViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
extension FirstTimeUserExperienceViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return screenshots.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:
        IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenshotCell", for: indexPath) as? ScreenshotCollectionViewCell else {
            fatalError("failed to dequeue screenshot cell")
        }
        cell.screenshotImageView.layer.cornerRadius = 4
        switch indexPath.section {
        case 0:
            let currentScreenshot = screenshots[0]
            cell.configureCell(screenshot: currentScreenshot)
            cell.infoLabel.text = """
            Welcome to CallBack!
            Browse your Job History
            """
            return cell
        case 1:
            let currentScreenshot = screenshots[1]
            cell.configureCell(screenshot: currentScreenshot)
            cell.infoLabel.text = """
            Welcome to CallBack!
            Practice Interview Questions
            """
            return cell
        case 2:
            let currentScreenshot = screenshots[2]
            cell.configureCell(screenshot: currentScreenshot)
            cell.infoLabel.text = """
            Welcome to CallBack!
            Enter your "S.T.A.R" Stories
            """
            return cell
        case 3:
            let currentScreenshot = screenshots[3]
            cell.configureCell(screenshot: currentScreenshot)
            cell.infoLabel.text = """
            Welcome to CallBack!
            Keep Track of your Job Applications
            """
            return cell
        default:
            let currentScreenshot = screenshots[0]
            cell.configureCell(screenshot: currentScreenshot)
            return cell
        }
    }
}
