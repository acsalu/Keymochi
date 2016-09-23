//
//  PAMAssessmentSheet.swift
//  PAM
//
//  Created by Huai-Che Lu on 9/23/16.
//  Copyright © 2016 Cornell Tech. All rights reserved.
//

import Foundation

public protocol PAMAssessmentSheetDelegate {
    func assessmentSheet(_: PAMAssessmentSheet, didSelectEmotion emotion: Emotion)
}

public enum PAMAssessmentSheetOption: Int {
    case minimum = 4
    case intermediate = 8
    case full = 16
    
    static let emotionTable: [PAMAssessmentSheetOption: [Emotion]] = [
        .minimum: [
            Emotion(1, 1)!, Emotion(1, 4)!, Emotion(4, 1)!, Emotion(4, 4)!
        ],
        .intermediate: [
            Emotion(1, 1)!, Emotion(2, 2)!, Emotion(3, 3)!, Emotion(4, 4)!,
            Emotion(4, 1)!, Emotion(3, 2)!, Emotion(2, 3)!, Emotion(1, 4)!
        ],
        .full: [
            Emotion(1, 1)!, Emotion(1, 2)!, Emotion(1, 3)!, Emotion(1, 4)!,
            Emotion(2, 1)!, Emotion(2, 2)!, Emotion(2, 3)!, Emotion(2, 4)!,
            Emotion(3, 1)!, Emotion(3, 2)!, Emotion(3, 3)!, Emotion(3, 4)!,
            Emotion(4, 1)!, Emotion(4, 2)!, Emotion(4, 3)!, Emotion(4, 4)!
        ]
    ]
}

public class PAMAssessmentSheet: UIView {
    var buttons = [UIButton]()
    public var delegate: PAMAssessmentSheetDelegate?
    var option: PAMAssessmentSheetOption!
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(frame: CGRect, option: PAMAssessmentSheetOption) {
        super.init(frame: frame)
        self.option = option
        
        let width = frame.size.width
        let buttonWidth = width / CGFloat(option.rawValue)
        for i in 0..<option.rawValue {
            let button = UIButton(frame: CGRect(x: buttonWidth * CGFloat(i), y: 0.0, width: buttonWidth, height: buttonWidth))
            button.addTarget(self, action: #selector(buttonSelected(sender:)), for: .touchUpInside)
            self.buttons.append(button)
        }
        
        self.buttons.enumerated().forEach { (offset, button) in
            self.addSubview(button)
            if let emotion = PAMAssessmentSheetOption.emotionTable[option]?[offset] {
                let image = PAMImage.loadRandomImage(forEmotion: emotion)
                button.setImage(image, for: .normal)
            }
        }
    }
    
    func buttonSelected(sender: UIButton) {
        guard let index = self.buttons.index(of: sender) else {
            return
        }
        
        guard let emotion = PAMAssessmentSheetOption.emotionTable[self.option]?[index] else {
            return
        }
        self.delegate?.assessmentSheet(self, didSelectEmotion: emotion)
    }
}
