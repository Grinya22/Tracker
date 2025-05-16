import UIKit

struct TrackerData {
    static func getCategories() -> [TrackerCategory] {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        
        // Трекеры для категории "Домашние дела" (5 трекеров)
        let homeTasks = [
            Tracker(id: UUID(), name: "Поливать растения", color: .ypGreen, emoji: "🌺", schedule: ["Пн", "Ср"], creationDate: Date()),
            Tracker(id: UUID(), name: "Утренняя зарядка", color: .ypLightOrange, emoji: "🙂", schedule: ["Пн", "Вт", "Чт", "Пт"], creationDate: Date()),
            Tracker(id: UUID(), name: "Уборка в комнате", color: .ypSoftGreen, emoji: "🧹", schedule: ["Ср", "Сб"], creationDate: Date()),
            Tracker(id: UUID(), name: "Готовка ужина", color: .ypCoral, emoji: "🍔", schedule: ["Пт", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Полить цветы", color: .ypLightGreen, emoji: "🥦", schedule: ["Вт", "Чт"], creationDate: Date())
        ]
        
        // Трекеры для категории "Развлечения" (7 трекеров)
        let entertainment = [
            Tracker(id: UUID(), name: "Встреча с друзьями", color: .ypBlue, emoji: "📅", schedule: [], creationDate: yesterday),
            Tracker(id: UUID(), name: "Чил в выходные", color: .ypMint, emoji: "😪", schedule: ["Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Поход в кино", color: .ypDeepBlue, emoji: "🎸", schedule: [], creationDate: yesterday),
            Tracker(id: UUID(), name: "Игра в теннис", color: .ypCoral, emoji: "🏓", schedule: ["Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Просмотр сериала", color: .ypViolet, emoji: "📺", schedule: ["Пт", "Сб"], creationDate: Date()),
            Tracker(id: UUID(), name: "Настольные игры", color: .ypLightBlue, emoji: "🎲", schedule: [], creationDate: yesterday),
            Tracker(id: UUID(), name: "Пикник на природе", color: .ypNeonGreen, emoji: "🏝", schedule: [], creationDate: yesterday)
        ]
        
        // Трекеры для категории "Уход за питомцами" (4 трекера)
        let petCare = [
            Tracker(id: UUID(), name: "Кошка на созвоне", color: .ypRed, emoji: "🐶", schedule: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Прогулка с собакой", color: .ypLightGreen, emoji: "🏝", schedule: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Кормление рыбок", color: .ypLightBlue, emoji: "🐠", schedule: ["Пн", "Ср", "Пт"], creationDate: Date()),
            Tracker(id: UUID(), name: "Игра с котом", color: .ypOrange, emoji: "😻", schedule: ["Вт", "Чт", "Сб"], creationDate: Date())
        ]
        
        // Трекеры для категории "Саморазвитие" (10 трекеров)
        let selfDevelopment = [
            Tracker(id: UUID(), name: "Чтение комиксов", color: .ypPink, emoji: "😇", schedule: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Изучение Swift", color: .ypViolet, emoji: "😱", schedule: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Медитация", color: .ypLightViolet, emoji: "🧘", schedule: ["Пн", "Ср", "Пт"], creationDate: Date()),
            Tracker(id: UUID(), name: "Изучение английского", color: .ypPurple, emoji: "📖", schedule: ["Вт", "Чт", "Сб"], creationDate: Date()),
            Tracker(id: UUID(), name: "Чтение книги", color: .ypDarkViolet, emoji: "📚", schedule: ["Пн", "Ср", "Пт"], creationDate: Date()),
            Tracker(id: UUID(), name: "Практика гитары", color: .ypStrongViolet, emoji: "🎸", schedule: ["Вт", "Чт", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Рисование", color: .ypLightOrange, emoji: "🎨", schedule: ["Сб", "Вс"], creationDate: Date()),
            Tracker(id: UUID(), name: "Йога", color: .ypSoftGreen, emoji: "🧘‍♀️", schedule: ["Пн", "Ср", "Пт"], creationDate: Date()),
            Tracker(id: UUID(), name: "Изучение истории", color: .ypDeepBlue, emoji: "🏰", schedule: ["Вт", "Чт"], creationDate: Date()),
            Tracker(id: UUID(), name: "Планирование дня", color: .ypNeonGreen, emoji: "📋", schedule: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"], creationDate: Date())
        ]
        
        return [
            TrackerCategory(title: "Домашние дела", trackers: homeTasks),
            TrackerCategory(title: "Развлечения", trackers: entertainment),
            TrackerCategory(title: "Уход за питомцами", trackers: petCare),
            TrackerCategory(title: "Саморазвитие", trackers: selfDevelopment)
        ]
    }
}
