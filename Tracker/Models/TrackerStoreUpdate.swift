import Foundation

struct TrackerStoreUpdate {
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}
