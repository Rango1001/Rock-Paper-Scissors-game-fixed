//
//  ViewController.swift
//  RockPaperScissors
//
//  Created by Peek A Boo on 2024-11-14.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var computerChoiseLabel: UILabel!
    @IBOutlet var playerChoisePickerView: UIPickerView!
    @IBOutlet var playerChoiseLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var playerScoreLabel: UILabel!
    @IBOutlet var computerScoreLabel: UILabel!
    @IBOutlet var difficultySegmentedControl: UISegmentedControl!

    let option = ["Rock", "Paper", "Scissors", "Lizard", "Spock"]
    var countdownTimer: Timer?
    var timerPausedAt: Date?
    var countdown = 3
    var playerScore = 0
    var computerScore = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSubviews()
        configureNotifications()
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func configureSubviews() {
        playerChoiseLabel.text = "You chose: Rock"
        playerScoreLabel.text = "Player Score: 0"
        computerScoreLabel.text = "Computer Score: 0"
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.minimumScaleFactor = 0.5
        resultLabel.numberOfLines = 1
        startButton.layer.cornerRadius = 10
        startButton.clipsToBounds = true
    }

    @objc private func handleAppBackground() {
        pauseTimer()
    }

    @objc private func handleAppForeground() {
        resumeTimer()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return option[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return option.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        playerChoiseLabel.text = "You chose: \(option[row])"
    }

    @IBAction func StartButtonPressed(_ sender: UIButton) {
        startCountdown()
    }

    func startCountdown() {
        resultLabel.text = "Let's see who wins"
        resultLabel.textColor = .systemBlue
        countdown = 3
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)

        startButton.isEnabled = false
        startButton.alpha = 0.5
    }

    @objc func updateCountdown() {
        if countdown > 0 {
            resultLabel.text = "\(countdown)"
            countdown -= 1
        } else {
            countdownTimer?.invalidate()
            let computerSelection = computerChoice()
            computerChoiseLabel.text = "Computer chose: \(computerSelection)"
            winLogic(computerSelection: computerSelection)

            startButton.isEnabled = true
            startButton.alpha = 1.0
        }
    }

    func pauseTimer() {
        if countdownTimer != nil {
            timerPausedAt = Date()
            countdownTimer?.invalidate()
        }
    }

    func resumeTimer() {
        guard let pausedAt = timerPausedAt else { return }
        let timeSpentPaused = Int(Date().timeIntervalSince(pausedAt))
        countdown -= timeSpentPaused

        if countdown > 0 {
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        } else {
            updateCountdown()
        }
    }

    func computerChoice() -> String {
        let selectedDifficulty = difficultySegmentedControl.selectedSegmentIndex

        if selectedDifficulty == 0 {
            return option.randomElement() ?? "Rock"
        } else if selectedDifficulty == 1 {
            let playerChoice = playerChoiseLabel.text?
                .replacingOccurrences(of: "You chose: ", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if Bool.random() {
                return option.randomElement() ?? "Rock"
            } else {
                switch playerChoice {
                case "Rock":
                    return "Paper"
                case "Paper":
                    return "Scissors"
                case "Scissors":
                    return "Rock"
                case "Lizard":
                    return "Rock"
                case "Spock":
                    return "Lizard"
                default:
                    return option.randomElement() ?? "Rock"
                }
            }
        } else {
            let playerChoice = playerChoiseLabel.text?
                .replacingOccurrences(of: "You chose: ", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            switch playerChoice {
            case "Rock":
                return "Paper"
            case "Paper":
                return "Scissors"
            case "Scissors":
                return "Rock"
            case "Lizard":
                return "Rock"
            case "Spock":
                return "Lizard"
            default:
                return option.randomElement() ?? "Rock"
            }
        }
    }

    func winLogic(computerSelection: String) {
        guard let playerChoice = playerChoiseLabel.text?
            .replacingOccurrences(of: "You chose: ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            resultLabel.text = "Error: Missing choices"
            return
        }

        let winCases = [
            ("Rock", "Scissors"), ("Rock", "Lizard"),
            ("Paper", "Rock"), ("Paper", "Spock"),
            ("Scissors", "Paper"), ("Scissors", "Lizard"),
            ("Lizard", "Paper"), ("Lizard", "Spock"),
            ("Spock", "Rock"), ("Spock", "Scissors")
        ]

        if playerChoice == computerSelection {
            resultLabel.text = "It's a tie!"
        } else if winCases.contains(where: { $0.0 == playerChoice && $0.1 == computerSelection }) {
            resultLabel.text = "You Won!"
            resultLabel.textColor = .systemGreen
            playerScore += 1
        } else {
            resultLabel.textColor = .systemRed
            resultLabel.text = "You Lost!"
            computerScore += 1
        }

        playerScoreLabel.text = "Player Score: \(playerScore)"
        computerScoreLabel.text = "Computer Score: \(computerScore)"

        UIView.animate(withDuration: 0.5, animations: {
            self.resultLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.resultLabel.transform = .identity
            }
        })

        startButton.setTitle("Play Again", for: .normal)
    }
}
