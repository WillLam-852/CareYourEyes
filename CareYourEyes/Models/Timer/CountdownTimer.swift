//
//  CountdownTimer.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 21/4/2023.
//

class CountdownTimer {
    
    var totalTime: TimeInterval
    var timeLeft: TimeInterval
    var timer: Timer? = nil
    
    init(totalTime: TimeInterval) {
        self.totalTime = totalTime
        self.timeLeft = totalTime
    }
    
    public func start(onTick: ((TimeInterval) -> Void)? = nil, onCompletion: (() -> Void)? = nil) {
        self.reset()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            self.timeLeft -= 0.1
            onTick?(self.timeLeft)
            if self.timeLeft <= 0 {
                self.stop()
                onCompletion?()
            }
        })
        self.timer!.fire()
    }
    
    public func stop() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    public func reset() {
        self.stop()
        self.timeLeft = totalTime
    }
}
