import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnaphootsTests: XCTestCase {

    func testOnboardingViewController() {
        let onboardingViewController = OnboardingViewController()
        assertSnapshot(matching: onboardingViewController, as: .image)
    }

    func testCreatingTrackerViewController() {
        let creatingTrackerViewController = CreatingTrackerViewController()
        assertSnapshot(matching: creatingTrackerViewController, as: .image)
    }

    func testCreatingIrregularEventViewController() {
        let creatingIrregularEventViewController = CreatingIrregularEventViewContoller()
        assertSnapshot(matching: creatingIrregularEventViewController, as: .image)
    }

    func testCreatingHabitViewController() {
        let creatingHabitViewController = CreatingHabitViewController()
        assertSnapshot(matching: creatingHabitViewController, as: .image)
    }

    func testCollectionTableViewController() {
        let collectionTableViewController = CollectionTableViewController()
        assertSnapshot(matching: collectionTableViewController, as: .image)
    }

    func testCreatingCollectionViewController() {
        let creatingCollectionViewController = CreatingCollectionViewController()
        assertSnapshot(matching: creatingCollectionViewController, as: .image)
    }

    func testEditCollectionViewController() {
        let editCollectionViewController = EditCollectionViewController()
        assertSnapshot(matching: editCollectionViewController, as: .image)
    }

    func testScheduleTableViewController() {
        let scheduleTableViewController = ScheduleTableViewController()
        assertSnapshot(matching: scheduleTableViewController, as: .image)
    }

    func testTrackersViewController() {
        let trackersViewController = TrackersViewController()
        assertSnapshot(matching: trackersViewController, as: .image)
    }

    func testFilterViewController() {
        let filterViewController = FilterViewController()
        assertSnapshot(matching: filterViewController, as: .image)
    }

    func testEditTrackerViewController() {
        let editTrackerViewController = EditTrackerViewController()
        assertSnapshot(matching: editTrackerViewController, as: .image)
    }
}
