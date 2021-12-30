import Foundation

let date = Date()
let calendar = Calendar.current
let time = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                   from: date)

print(time.year)
