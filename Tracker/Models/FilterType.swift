import Foundation

enum FilterType {
    case all
    case today(Date)
    case completed(Date)
    case uncompleted(Date)
}
