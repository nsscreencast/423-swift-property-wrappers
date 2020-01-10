import Foundation

@propertyWrapper
struct PrintAccess<Value> {

    private var value: Value

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
        get {
            print("Getting the value")
            return value
        }
        set {
            print("Setting the value to \(newValue)")
            value = newValue
        }
    }
}

struct Student {
    @PrintAccess
    var grade: Double

    @PrintAccess
    var credits: Int = 0
}


var student = Student(grade: 75)
student.grade = 90
print(student.grade)

student.credits += 1
print(student.credits)


@propertyWrapper
struct Trimmed {
    private var value: String

    init(wrappedValue value: String) {
        self.value = value
        wrappedValue = value
    }

    var wrappedValue: String {
        get { value }
        set {
            value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

struct User {
    @Trimmed
    var username: String
}

let user = User(username: "ben   ")
print("[\(user.username)]")

@propertyWrapper
struct Clamped<Value : Comparable> {
    @PrintAccess
    private var value: Value
    private var range: ClosedRange<Value>

    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = value
        self.range = range
    }

    var wrappedValue: Value {
        get { value }
        set {
//            if newValue < range.lowerBound {
//                value = range.lowerBound
//            } else if newValue > range.upperBound {
//                value = range.upperBound
//            } else {
//                value = newValue
//            }
            value = min(range.upperBound, max(range.lowerBound, newValue))
        }
    }
}

struct Player {
    @Clamped(0...100)
    var speed: Double = 100
}

var player = Player()
player.speed = 25
player.speed = 125


@propertyWrapper
struct AuditLog<Value> {
    private var value: Value
    private(set) var changes: [(Date, Value)] = []
    private let maxHistory = 10

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
        get {
            value
        }
        set {
            value = newValue
            changes.append((Date(), newValue))
            if changes.count > maxHistory {
                changes.removeFirst()
            }
        }
    }

    var projectedValue: Self {
        self
    }
}

struct Account {
    @AuditLog
    private(set) var balance: Double

    mutating func deposit(_ amount: Double) {
        balance += amount
    }

    mutating func withdraw(_ amount: Double) {
        balance -= amount
    }

    func audit() {
        print(_balance.changes)
    }
}

var account = Account(balance: 100)
account.deposit(15)
account.deposit(27)
account.withdraw(75)

print(account.balance)
print(account.$balance.changes)
