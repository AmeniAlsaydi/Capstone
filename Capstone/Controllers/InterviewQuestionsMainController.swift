//
//  InterviewQuestionsMainController.swift
//  Capstone
//
//  Created by Amy Alsaydi on 5/26/20.
//  Copyright © 2020 Amy Alsaydi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

enum FilterState {
    case common
    case custom
    case bookmarked
    case all
}

class InterviewQuestionsMainController: UIViewController {
    
    @IBOutlet weak var questionsCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButtonsStack: UIStackView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var bookmarksButton: UIButton!
    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var customButton: UIButton!
    
    private var listener: ListenerRegistration?
    private var isFilterOn = false {
        didSet {
            if isFilterOn {
                //TODO: when filter is hidden, snap the collectionview to search bar
                filterButtonsStack.isHidden = false
            } else {
                filterButtonsStack.isHidden = true
            }
        }
    }
    public var filterState: FilterState = .all {
        didSet {
            questionsCollectionView.reloadData()
        }
    }
    private var commonInterviewQuestions = [InterviewQuestion]() {
        didSet{
            if filterState == .common {
                questionsCollectionView.reloadData()
            }
        }
    }
    private var customQuestions = [InterviewQuestion]() {
        didSet {
            if filterState == .custom {
                if customQuestions.isEmpty {
                    questionsCollectionView.backgroundView = EmptyView.init(title: "No Custom Questions Created", message: "Add a question by pressing the plus button", imageName: "questionmark.square.fill")
                } else {
                    questionsCollectionView.reloadData()
                    questionsCollectionView.backgroundView = nil
                }
            }
        }
    }
    private var allQuestions = [InterviewQuestion]() {
        didSet {
            if filterState == .all {
                questionsCollectionView.reloadData()
                questionsCollectionView.backgroundView = nil
            }
        }
    }
    private var bookmarkedQuestions = [InterviewQuestion]() {
        didSet {
            if filterState == .bookmarked {
                questionsCollectionView.reloadData()
                if bookmarkedQuestions.isEmpty {
                    questionsCollectionView.backgroundView = EmptyView.init(title: "No Bookmarks", message: "Add to your bookmarks collection by selecting a question and pressing the bookmark button", imageName: "bookmark")
                } else {
                    questionsCollectionView.reloadData()
                    questionsCollectionView.backgroundView = nil
                }
            }
        }
    }
    private var searchQuery = String() {
        didSet {
            DispatchQueue.main.async {
                switch self.filterState {
                case .all:
                    self.allQuestions = self.allQuestions.filter {$0.question.lowercased().contains(self.searchQuery.lowercased())}
                case .common:
                    self.commonInterviewQuestions = self.commonInterviewQuestions.filter {$0.question.lowercased().contains(self.searchQuery.lowercased())}
                case .custom:
                    self.customQuestions = self.customQuestions.filter {$0.question.lowercased().contains(self.searchQuery.lowercased())}
                case .bookmarked:
                    self.bookmarkedQuestions = self.bookmarkedQuestions.filter {$0.question.lowercased().contains(self.searchQuery.lowercased())}
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateUI()
        guard let user = Auth.auth().currentUser else {return}
        listener = Firestore.firestore().collection(DatabaseService.userCollection).document(user.uid).collection(DatabaseService.customQuestionsCollection).addSnapshotListener({ [weak self] (snapshot, error) in
            if let error = error {
                print("listener could not recieve changes for custom questions error: \(error.localizedDescription)")
            } else if let snapshot = snapshot {
                let customQs = snapshot.documents.map {InterviewQuestion($0.data())}
                self?.customQuestions = customQs
                self?.questionsCollectionView.reloadData()
            }
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        updateUI()
        configureCollectionView()
        configureNavBar()
        getInterviewQuestions()
        getUserCreatedQuestions()
        getBookmarkedQuestions()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener?.remove()
    }
    //MARK:- UI
    private func updateUI() {
        view.backgroundColor = AppColors.complimentaryBackgroundColor
        isFilterOn = false
        questionsCollectionView.backgroundColor = .clear
        buttonsUI()
        roundButtons()
    }
    private func buttonsUI() {
        allButton.titleLabel?.font = AppFonts.semiBoldSmall
        bookmarksButton.titleLabel?.font = AppFonts.semiBoldSmall
        commonButton.titleLabel?.font = AppFonts.semiBoldSmall
        customButton.titleLabel?.font = AppFonts.semiBoldSmall
        allButton.tintColor = AppColors.whiteTextColor
        allButton.backgroundColor = AppColors.secondaryPurpleColor
        bookmarksButton.tintColor = AppColors.whiteTextColor
        bookmarksButton.backgroundColor = AppColors.secondaryPurpleColor
        commonButton.tintColor = AppColors.whiteTextColor
        commonButton.backgroundColor = AppColors.secondaryPurpleColor
        customButton.tintColor = AppColors.whiteTextColor
        customButton.backgroundColor = AppColors.secondaryPurpleColor
    }
    private func roundButtons() {
        allButton.layer.cornerRadius = 13
        bookmarksButton.layer.cornerRadius = 13
        commonButton.layer.cornerRadius = 13
        customButton.layer.cornerRadius = 13
    }
    //MARK:- Config NavBar and Bar Button Method
    private func configureNavBar() {
        navigationItem.title = "Interview Questions"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: AppButtonIcons.plusIcon, style: .plain, target: self, action: #selector(addInterviewQuestionButtonPressed(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: AppButtonIcons.filterIcon, style: .plain, target: self, action: #selector(presentfilterMenuButtonPressed(_:)))
    }
    @objc func addInterviewQuestionButtonPressed(_ sender: UIBarButtonItem) {
        let interviewQuestionEntryVC = InterviewQuestionEntryController(nibName: "InterviewQuestionEntryXib", bundle: nil)
        present(UINavigationController(rootViewController: interviewQuestionEntryVC), animated: true)
    }
    //MARK:- FilterMenu
    @objc func presentfilterMenuButtonPressed(_ sender: UIBarButtonItem) {
        isFilterOn.toggle()
    }
    //MARK:- Config Collection View
    private func configureCollectionView() {
        questionsCollectionView.keyboardDismissMode = .onDrag
        questionsCollectionView.delegate = self
        questionsCollectionView.dataSource = self
        questionsCollectionView.register(UINib(nibName: "InterviewQuestionCellXib", bundle: nil), forCellWithReuseIdentifier: "interviewQuestionCell")
    }
    //MARK:- Get Data
    private func getInterviewQuestions() {
        DatabaseService.shared.fetchCommonInterviewQuestions { [weak self] (result) in
            switch result {
            case .failure(let error) :
                print("could not fetch common interview questions from firebase error: \(error.localizedDescription)")
            case .success(let questions):
                DispatchQueue.main.async {
                    self?.commonInterviewQuestions = questions
                    self?.allQuestions.append(contentsOf: questions)
                }
            }
        }
    }
    private func getUserCreatedQuestions() {
        DatabaseService.shared.fetchCustomInterviewQuestions { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("unable to retrieve custom questions error: \(error.localizedDescription)")
            case .success(let customQuestions):
                DispatchQueue.main.async {
                    self?.customQuestions = customQuestions
                    self?.allQuestions.append(contentsOf: customQuestions)
                }
            }
        }
    }
    private func getBookmarkedQuestions() {
        DatabaseService.shared.fetchBookmarkedQuestions { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("unable to retrieve bookmarked questions error: \(error.localizedDescription)")
            case .success(let bookmarks):
                DispatchQueue.main.async {
                    self?.bookmarkedQuestions = bookmarks
                }
            }
        }
    }
    @IBAction func allButtonPressed(_ sender: UIButton) {
        allButton.tintColor = AppColors.whiteTextColor
        allButton.backgroundColor = AppColors.primaryPurpleColor
        bookmarksButton.tintColor = AppColors.whiteTextColor
        bookmarksButton.backgroundColor = AppColors.secondaryPurpleColor
        commonButton.tintColor = AppColors.whiteTextColor
        commonButton.backgroundColor = AppColors.secondaryPurpleColor
        customButton.tintColor = AppColors.whiteTextColor
        customButton.backgroundColor = AppColors.secondaryPurpleColor
        filterState = .all
    }
    @IBAction func bookmarksButtonPressed(_ sender: UIButton) {
        allButton.tintColor = AppColors.whiteTextColor
        allButton.backgroundColor = AppColors.secondaryPurpleColor
        bookmarksButton.tintColor = AppColors.whiteTextColor
        bookmarksButton.backgroundColor = AppColors.primaryPurpleColor
        commonButton.tintColor = AppColors.whiteTextColor
        commonButton.backgroundColor = AppColors.secondaryPurpleColor
        customButton.tintColor = AppColors.whiteTextColor
        customButton.backgroundColor = AppColors.secondaryPurpleColor
        filterState = .bookmarked
    }
    @IBAction func commonButtonPressed(_ sender: UIButton) {
        allButton.tintColor = AppColors.whiteTextColor
        allButton.backgroundColor = AppColors.secondaryPurpleColor
        bookmarksButton.tintColor = AppColors.whiteTextColor
        bookmarksButton.backgroundColor = AppColors.secondaryPurpleColor
        commonButton.tintColor = AppColors.whiteTextColor
        commonButton.backgroundColor = AppColors.primaryPurpleColor
        customButton.tintColor = AppColors.whiteTextColor
        customButton.backgroundColor = AppColors.secondaryPurpleColor
        filterState = .common
    }
    @IBAction func customButtomPressed(_ sender: UIButton) {
        allButton.tintColor = AppColors.whiteTextColor
        allButton.backgroundColor = AppColors.secondaryPurpleColor
        bookmarksButton.tintColor = AppColors.whiteTextColor
        bookmarksButton.backgroundColor = AppColors.secondaryPurpleColor
        commonButton.tintColor = AppColors.whiteTextColor
        commonButton.backgroundColor = AppColors.secondaryPurpleColor
        customButton.tintColor = AppColors.whiteTextColor
        customButton.backgroundColor = AppColors.primaryPurpleColor
        filterState = .custom
    }
}
//MARK:- CollectionView Delegate and DataSource
extension InterviewQuestionsMainController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxsize: CGSize = UIScreen.main.bounds.size
        let itemWidth: CGFloat = maxsize.width * 0.9
        let itemHeight: CGFloat = maxsize.height * 0.2
        return CGSize(width: itemWidth, height: itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let interviewAnswerVC = InterviewAnswerDetailController(nibName: "InterviewAnswerDetailXib", bundle: nil)
        switch filterState{
        case .all:
            let question = allQuestions[indexPath.row]
            interviewAnswerVC.question = question
        case.common:
            let question = commonInterviewQuestions[indexPath.row]
            interviewAnswerVC.question = question
        case .custom:
            let question = customQuestions[indexPath.row]
            interviewAnswerVC.question = question
        case.bookmarked:
            let question = bookmarkedQuestions[indexPath.row]
            interviewAnswerVC.question = question
        }
        navigationController?.pushViewController(interviewAnswerVC, animated: true)
    }
}
extension InterviewQuestionsMainController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch filterState {
        case .all:
            return allQuestions.count
        case .bookmarked:
            return bookmarkedQuestions.count
        case .custom:
            return customQuestions.count
        case .common:
            return commonInterviewQuestions.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = questionsCollectionView.dequeueReusableCell(withReuseIdentifier: "interviewQuestionCell", for: indexPath) as? InterviewQuestionCell else {
            fatalError("could not cast to interviewquestioncell")
        }
        switch filterState {
        case .all:
            let question = allQuestions[indexPath.row]
            cell.configureCell(interviewQ: question)
            cell.currentQuestion = question
            let customQs = customQuestions.map {$0.question}
            if customQs.contains(question.question) {
                cell.editButton.isHidden = false
            } else {
                cell.editButton.isHidden = true
            }
        case .common:
            let question = commonInterviewQuestions[indexPath.row]
            cell.configureCell(interviewQ: question)
            cell.currentQuestion = question
            let customQs = customQuestions.map {$0.question}
            if customQs.contains(question.question) {
                cell.editButton.isHidden = false
            } else {
                cell.editButton.isHidden = true
            }
        case .custom:
            let question = customQuestions[indexPath.row]
            cell.configureCell(interviewQ: question)
            cell.currentQuestion = question
            cell.editButton.isHidden = false
        case .bookmarked:
            let question = bookmarkedQuestions[indexPath.row]
            cell.configureCell(interviewQ: question)
            cell.currentQuestion = question
            let customQs = customQuestions.map {$0.question}
            if customQs.contains(question.question) {
                cell.editButton.isHidden = false
            } else {
                cell.editButton.isHidden = true
            }
        }
        cell.delegate = self
        return cell
    }
}
//MARK:- Search Bar Delegate
extension InterviewQuestionsMainController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty ?? false) {
            getInterviewQuestions()
        } else {
            searchQuery = searchBar.text ?? ""
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
extension InterviewQuestionsMainController: InterviewQuestionCellDelegate {
    func presentMenu(cell: InterviewQuestionCell, question: InterviewQuestion) {
        guard let indexPath = questionsCollectionView.indexPath(for: cell) else {
            return
        }
        let customQuestion: InterviewQuestion?
        if filterState == .custom {
            customQuestion = customQuestions[indexPath.row]
            cell.currentQuestion = customQuestion
        } else {
            customQuestion = allQuestions[indexPath.row]
            cell.currentQuestion = customQuestion
        }
        
        let optionsMenu = UIAlertController(title: "Custom Question Options", message: nil, preferredStyle: .actionSheet)
        let edit = UIAlertAction(title: "Edit Custom Question", style: .default) { [weak self] (action) in
            let interviewQuestionEntryVC = InterviewQuestionEntryController(nibName: "InterviewQuestionEntryXib", bundle: nil)
            interviewQuestionEntryVC.editingMode = true
            interviewQuestionEntryVC.customQuestion = customQuestion
            self?.present(UINavigationController(rootViewController: interviewQuestionEntryVC), animated: true)
        }
        let delete = UIAlertAction(title: "Remove", style: .destructive) { [weak self] (action) in
            DatabaseService.shared.deleteCustomQuestion(customQuestion: customQuestion!) { [weak self] (result) in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Error", message: "Could not remove question at this time error: \(error.localizedDescription)")
                    }
                case .success:
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Question Removed", message: "\(customQuestion!.question) has been removed")
                        if self?.filterState == .custom {
                            if !(self?.customQuestions.isEmpty ?? false) {
                                self?.customQuestions.remove(at: indexPath.row)
                                self?.questionsCollectionView.reloadData()
                            }
                        } else {
                            self?.allQuestions.remove(at: indexPath.row)
                            self?.questionsCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            self?.dismiss(animated: true)
        }
        optionsMenu.addAction(edit)
        optionsMenu.addAction(delete)
        optionsMenu.addAction(cancel)
        present(optionsMenu, animated: true, completion: nil)
    }
}
