import Foundation

/// Turns raw sessions into the quiet, badge-free numbers shown on the stats screen.
struct ComputeStatsUseCase: Sendable {
    func execute(sessions: [BreathSession], calendar: Calendar = .current, now: Date = .now) -> BreathStats {
        guard !sessions.isEmpty else { return .empty }

        let totalSeconds = sessions.reduce(0) { $0 + $1.duration }
        let totalMinutes = Int((totalSeconds / 60).rounded())

        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.startTime) })
        let streak = currentStreak(sessionDays: sessionDays, calendar: calendar, now: now)
        let lastWeek = dailyMinutes(sessions: sessions, dayCount: 7, calendar: calendar, now: now)
        let lastMonth = dailyMinutes(sessions: sessions, dayCount: 30, calendar: calendar, now: now)

        return BreathStats(
            totalMinutes: totalMinutes,
            currentStreakDays: streak,
            totalSessions: sessions.count,
            dailyMinutesLastWeek: lastWeek,
            dailyMinutesLastMonth: lastMonth
        )
    }

    private func currentStreak(sessionDays: Set<Date>, calendar: Calendar, now: Date) -> Int {
        var streak = 0
        var day = calendar.startOfDay(for: now)

        if !sessionDays.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
            guard sessionDays.contains(day) else { return 0 }
        }

        while sessionDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    private func dailyMinutes(sessions: [BreathSession], dayCount: Int, calendar: Calendar, now: Date) -> [Double] {
        let today = calendar.startOfDay(for: now)
        var minutesByDay: [Date: Double] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.startTime)
            minutesByDay[day, default: 0] += session.duration / 60
        }

        return (0..<dayCount).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return minutesByDay[day] ?? 0
        }
    }
}
