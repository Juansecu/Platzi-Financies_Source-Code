import Foundation

// Structure Way

// Classes way
extension Date {
    init(year: Int, month: Int, day: Int) {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        self = calendar.date(from: dateComponents) ?? Date()
    }
}

protocol InvalidateTransaction {
    func InvalidateTransaction(Transaction: Transaction)
}

typealias TransactionHandler = ((_ completed: Bool, _ confirmation: Date) -> Void)

protocol Transaction {
    var date: Date { get }
    var name: String { get }
    var value: Float { get }
    var isValid: Bool { get set }
    var delegate: InvalidateTransaction? { get set}
    var handler: TransactionHandler? { get set }
    var completed:Bool { get }
    var confirmation: Date? { get set }
}

extension Transaction {
    mutating func InvalidateTransaction() {
        if completed {
            isValid = false
            delegate?.InvalidateTransaction(Transaction: self)
        }
    }
}

protocol TransactionDebit: Transaction {
    var category: DebitCategories { get }
}

enum DebitCategories {
    case Health, Food, Rent, Tax, Transportation, Entertainment
}

enum TransactionType {
    case Debit(date: Date, name: String, value: Float, category: DebitCategories)
    case Gain(date: Date, name: String, value: Float)
}

class Debit: TransactionDebit {
    var date: Date
    var name: String
    var value: Float
    var category: DebitCategories
    var isValid: Bool = true
    var delegate: InvalidateTransaction?
    var handler: TransactionHandler?
    var completed: Bool = false
    var confirmation: Date?
    
    init(date: Date, name: String, value: Float, category: DebitCategories) {
        self.date = date
        self.name = name
        self.value = value
        self.category = category
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.handler?(true, Date())
            print("Transacción Confirmada!", Date())
        }
    }
}

class Gain: Transaction {
    var date: Date
    var name: String
    var value: Float
    var isValid: Bool = true
    var delegate: InvalidateTransaction?
    var handler: TransactionHandler?
    var completed: Bool = false
    var confirmation: Date?
    
    init(date: Date, name: String, value: Float) {
        self.date = date
        self.name = name
        self.value = value
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handler?(true, Date())
            print("Transacción Confirmada!", Date())
        }
    }
}

class Account {
    var Ammount: Float = 0 {
        willSet {
            print("Vamos a cambiar el valor de", Ammount, "a", newValue)
        }
        
        didSet {
            print("Tenemos nuevo valor:", Ammount)
        }
    }
    
    var Name: String = ""
    var Transactions: [Transactions] = []
    
    var Debits: [Debit] = []
    var Gains: [Gain] = []
    
    init(Ammount: Float, Name: String) {
        self.Ammount = Ammount
        self.Name = Name
    }
    
    @discardableResult
    func addTransaction(Transaction: TransactionType) -> Transaction? {
        switch Transaction {
            case .Debit(let date, let name, let value, let category):
                if (Ammount - value) < 0 {
                    return nil
                }
                
                let debit = Debit(date: date, name: name, value: value, category: category)
                
                debit.delegate = self
                debit.handler = { (completed, confirmation) in
                    self.Ammount -= debit.value
                    
                    // self.Transactions.append(debit)
                    self.Debits.append(debit)
                    debit.confirmation = confirmation
                }

                return debit
            case .Gain(let date, let name, let value):
                let gain = Gain(date: date, name: name, value: value)
                
                gain.delegate = self
                gain.handler = { (completed, confirmation) in
                    self.Ammount += gain.value
                    
                    // Transactions.append(gain)
                    self.Gains.append(gain)
                    gain.confirmation = confirmation
                }
                
                return gain
        }
    }
    
    func TransactionsFor(category: DebitCategories) -> [Transactions] {
        return Transactions.filter({ (Transaction) -> Bool in
            guard let Transaction = Transaction as? Debit else {
                return false
            }
            
            return Transaction.category == category
        })
    }
}

extension Account: InvalidateTransaction {
    func InvalidateTransaction(Transaction: Transaction) {
        if Transaction is Debit {
            Ammount += Transaction.value
        }
        
        if Transaction is Gain {
            Ammount -= Transaction.value
        }
    }
}

class Person {
    var Name: String = ""
    var LastName: String = ""
    var FullName: String {
        get {
            return "\(Name) \(LastName)"
        }
        
        set {
            Name = String(newValue.split(separator: " ").first ?? "")
            LastName = "\(newValue.split(separator: " ").last ?? "")"
        }
    }
    var Account: Account?
    
    init(Name: String, LastName: String) {
        self.Name = Name
        self.LastName = LastName
    }
}

class Transactions {
    var value: Float
    var name: String
    
    init(value: Float, name: String) {
        self.value = value
        self.name = name
    }
}

var me = Person(Name: "Juan", LastName: "Cuello")

// Structs way
/*struct Account {
    var Ammount: Float = 0
    var Name: String = ""
    var Transactions: [Float] = []
    
    init(Ammount: Float, Name: String) {
        self.Ammount = Ammount
        self.Name = Name
    }
    
    @discardableResult
    mutating func addTransaction(value: Float) -> Float {
        if (Ammount - value) < 0 {
            return 0
        }
        
        Ammount -= value
        Transactions.append(value)
        
        return Ammount
    }
}

struct Person {
    var Name: String
    var LastName: String
    var Account: Account?
}

var me = Person(Name: "Juan", LastName: "Cuello", Account: nil)*/

let account = Account(Ammount: 100_000, Name: "X bank")

me.Account = account

print(me.Account!)

account.addTransaction(Transaction: .Debit(date: Date(year: 2010, month: 11, day: 15), name: "Cafecito con BadG", value: 20, category: DebitCategories.Food))
me.Account?.addTransaction(Transaction: .Debit(date: Date(year: 2019, month: 11, day: 30), name: "Capuccino", value: 20, category: DebitCategories.Food))
me.Account?.addTransaction(Transaction: .Debit(date: Date(year: 2019, month: 12, day: 16), name: "Celular", value: 360, category: .Entertainment))
me.Account?.addTransaction(Transaction: .Gain(date: Date(year: 2019, month: 12, day: 11), name: "Salario", value: 1000))
var salary = me.Account?.addTransaction(Transaction: .Gain(date: Date(year: 2019, month: 12, day: 16), name: "Salario", value: 1000))
me.Account?.addTransaction(Transaction: .Gain(date: Date(year: 2019, month: 12, day: 14), name: "Donacion", value: 100))
account.addTransaction(Transaction: .Gain(date: Date(year: 2019, month: 12, day: 20), name: "Prima", value: 300))

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    salary?.InvalidateTransaction()
    print("Transacción Invalidada!")
}

print(me.Account!.Ammount)

print(me.FullName)

me.FullName = "Specter Shadenotable"

print(me.LastName)
print(me.Name)

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    let transactions = me.Account?.TransactionsFor(category: .Entertainment) as? [Debit]
    
    for Transaction in transactions ?? [] {
        print("Hello", Transaction.date, Transaction.name, Transaction.value, Transaction.category)
    }
    
    for Gain in me.Account?.Gains ?? [] {
        print("Hello gain", Gain.date, Gain.name, Gain.value, Gain.isValid)
    }
}

print(me.Account?.Ammount ?? 0)



// Copy Way
/*var accountTotal: Float = 1_000_000_000

let Name = "andrés"
let LastName = "silva"

let FullName = "\(Name) \(LastName)"

print(FullName.capitalized)

// accountTotal = accountTotal + 100_000
accountTotal += 100_000

print(accountTotal)

// 1e7 = 1 with seven 0
var account = 1e7

print(account)

var isActive = !FullName.isEmpty

print(isActive)

var Age = 27
var Ammount = 3010030231 as NSNumber
var formatter = NumberFormatter()
formatter.numberStyle = .currency

print(FullName.capitalized + ", " + String(Age) + " años, con un Saldo de \((formatter.string(from: Ammount) ?? "")) en su cuenta de ahorros.")

var Transactions: [Float] = [20, 10, 100]

print(Transactions)

Transactions.count
Transactions.isEmpty

Transactions.append(40)

print(Transactions)

Transactions.first
Transactions.last

Transactions.removeLast()

Transactions.last

// Transactions.removeFirst()
// Transactions.removeAll()

Transactions.min()
Transactions.max()

var daylyTransactions: [[Float]] = [
    [20, 10, 100],
    [],
    [1000],
    [],
    [10]
]

daylyTransactions.first
daylyTransactions[1].isEmpty

var transactionsDict: [String: [Float]] = [
    "1nov": [20, 10, 100],
    "2nov": [],
    "3nov": [1000],
    "4nov": [],
    "5nov": [10]
]

var transactionsDict2: [String: [Float]] = [
    "2dec": [1000],
    "3dec": [1000],
    "4dec": [1000]
]

print(transactionsDict["1nov"]!)
print(transactionsDict.keys)
print(transactionsDict.values)
print(transactionsDict.isEmpty)
print(transactionsDict.count)

if accountTotal > 0 {
    print("Tengo algo de dinero")
} else if accountTotal > 50_000_000 {
    print("Es hora de viajar!")
} else {
    print("Hay que seguir ahorrando!")
}

/* if/else simplified:
 * ? = Result when condition is true
 * : = Result when condition is false
 */
let hasMoney = accountTotal > 1_000_000_000 ? "Es hora de viajar!" : "Tengo algo de dinero"

print(hasMoney)

var age = 20
var tax: Float = 1

// ... = Rangos
switch age {
case 0 ... 17:
    print("No podemos dar una tarjeta de crédito.")
case 18 ... 22:
    tax = 2
    print("La tasa de interés es del \((tax))%")
case 23 ... 28:
    tax = 3.5
    print("La tasa de interés es del 3.5%")
default:
    print("La tasa de interés es del 1%")
}

let bankType = "B"

switch bankType {
case "B":
    print("Es el banco B.")
default:
    print("Es otro banco.")
}

var Total: Float = 0
for Transacttion in Transactions {
    Total += Transacttion
}

print(Total)

print(accountTotal)

accountTotal -= Total

print(accountTotal)

var Total2: Float = 0

for Key in transactionsDict.keys {
    for Transaction in transactionsDict[Key] ?? [] {
        Total2 += Transaction
    }
}

for Key in transactionsDict.keys {
    for Transaction in transactionsDict[Key]! where Transaction > 30 {
        Total2 += Transaction
    }
}

print(Transactions)

var Total3 = Transactions.reduce(0.0) { (result, element) -> Float in
    return result + element
}

print(Transactions.reduce(0.0, { return $0 + $1 }))

print(Transactions.reduce(0.0, { $0 + $1 }))

print(Transactions.reduce(0.0, +))

print(Total3)

print(transactionsDict)

print(Total2)

var newTransactions = Transactions.map { (element) -> Float in
    return element * 100
}

print(newTransactions)

print(Transactions.sorted())

print(Transactions.sorted(by: { (element1, element2) -> Bool in
    return element1 > element2
}))

print(Transactions.filter { (element) -> Bool in
    return element > 10
})

Transactions.removeAll(where: {
    $0 > 10
})

print(Transactions)

var name: String?

print(name ?? "No tenemos nombre")

name = "Andrés"

if let name = name {
    print(name)
}

print(name!)

// First Method
/*func totalAccount(_ Transactions: [String: [Float]]) {
 var total: Float = 0
 for key in Transactions.keys {
 let array = Transactions[key]!
 total += array.reduce(0.0, +)
 }
 
 print(total)
 }
 
 totalAccount(transactionsDict)*/

// Second Method
func totalAccount(forTransactions Transactions: [String: [Float]]) -> (Float, Int) {
    var total: Float = 0
    for key in Transactions.keys {
        let array = Transactions[key]!
        total += array.reduce(0.0, +)
    }
    
    return (total, Transactions.count)
}

let total = totalAccount(forTransactions: transactionsDict)
let total2 = totalAccount(forTransactions: transactionsDict2)

print(total.0, total.1)
print(total2)

let name2 = (Name: "Andrés", LastName: "Silva")
print(name2.Name)
print(name2.LastName)

// First Method
/*var a = 1
 var b = 2
 var c = 0
 
 c = a
 a = b
 b = c
 
 print(a, b)*/

// Tupla Method
var a = 1
var b = 2

(a, b) = (b, a)

print(a, b)

@discardableResult
func addTransaction(transactionValue value: Float? = nil) -> Bool {
    guard let value = value else {
        return false
    }
    
    if (accountTotal - value) < 0 {
        return false
    }
    accountTotal -= value
    Transactions.append(value)
    return true
}

addTransaction(transactionValue: 30)

addTransaction()*/
