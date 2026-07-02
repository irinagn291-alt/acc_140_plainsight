import Foundation

/// Quiet, badge-free summary of a person's practice.
struct BreathStats: Equatable, Sendable {
    let totalMinutes: Int
    let currentStreakDays: Int
    let totalSessions: Int
    /// Minutes practiced per day for the last 7 days, oldest first.
    let dailyMinutesLastWeek: [Double]
    /// Minutes practiced per day for the last 30 days, oldest first.
    let dailyMinutesLastMonth: [Double]

    static let empty = BreathStats(
        totalMinutes: 0,
        currentStreakDays: 0,
        totalSessions: 0,
        dailyMinutesLastWeek: Array(repeating: 0, count: 7),
        dailyMinutesLastMonth: Array(repeating: 0, count: 30)
    )
}
