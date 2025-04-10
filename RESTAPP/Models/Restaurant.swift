//
//  Restaurant.swift
//  RESTAPP
//
//  Created by Artem Samsonov on 04.02.2025.
//


import Foundation

struct Restaurant: Codable {
    let id: String
    let name: String
    let openingHours: OpeningHours
    
    struct OpeningHours: Codable {
        struct DaySchedule: Codable {
            let open: String?
            let close: String?
        }
        
        let monday: DaySchedule
        let tuesday: DaySchedule
        let wednesday: DaySchedule
        let thursday: DaySchedule
        let friday: DaySchedule
        let saturday: DaySchedule
        let sunday: DaySchedule
        
        private func timeToMinutes(_ timeString: String?) -> Int? {
            guard let timeString = timeString else { return nil }
            let components = timeString.split(separator: ":")
            guard components.count == 2,
                  let hours = Int(components[0]),
                  let minutes = Int(components[1])
            else { return nil }
            return hours * 60 + minutes
        }
        
        private func scheduleForWeekday(_ weekday: Int) -> DaySchedule {
            switch weekday {
            case 2: return monday
            case 3: return tuesday
            case 4: return wednesday
            case 5: return thursday
            case 6: return friday
            case 7: return saturday
            case 1: return sunday
            default: return monday
            }
        }
        
        var isCurrentlyOpen: Bool {
            let calendar = Calendar.current
            let now = Date()
            
            let weekday = calendar.component(.weekday, from: now)
            let schedule = scheduleForWeekday(weekday)
            
            guard let openTime = schedule.open,
                  let closeTime = schedule.close else {
                return false
            }
            
            let components = calendar.dateComponents([.hour, .minute], from: now)
            let currentMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            
            let openMinutes = timeToMinutes(openTime) ?? 0
            let closeMinutes = timeToMinutes(closeTime) ?? 0
            
            if closeMinutes < openMinutes {
                return currentMinutes >= openMinutes || currentMinutes <= closeMinutes
            } else {
                return currentMinutes >= openMinutes && currentMinutes <= closeMinutes
            }
        }
        
        var currentDaySchedule: String {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            let schedule = scheduleForWeekday(weekday)
            
            if let open = schedule.open, let close = schedule.close {
                return "\(open) - \(close)"
            } else {
                return "Закрыто"
            }
        }
        
        var fullSchedule: String {
            var schedule = [String]()
            
            let addDay = { (day: String, daySchedule: DaySchedule) in
                if let open = daySchedule.open, let close = daySchedule.close {
                    schedule.append("\(day): \(open) - \(close)")
                } else {
                    schedule.append("\(day): Закрыто")
                }
            }
            
            addDay("Пн", monday)
            addDay("Вт", tuesday)
            addDay("Ср", wednesday)
            addDay("Чт", thursday)
            addDay("Пт", friday)
            addDay("Сб", saturday)
            addDay("Вс", sunday)
            
            return schedule.joined(separator: "\n")
        }
    }
    
    var isOpen: Bool {
        openingHours.isCurrentlyOpen
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case openingHours
    }
} 
