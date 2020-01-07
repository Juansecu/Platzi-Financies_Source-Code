import Foundation

class Person {
    var account: Account?
    var name = "Sebastian"
    
    deinit {
        print("Vamos a eliminar esta persona:")
    }
}

class Account {
    unowned var person: Person
    var name = "Bank X"
    
    init(person: Person) {
        self.person = person
    }
    
    deinit {
        print("Vamos a eliminar esta cuenta:")
    }
}

var person: Person = Person()
var account: Account? = Account(person: person)

account?.person = person

print(person.account?.name)
print(account!.person.name)

account = nil

print(person.account?.name)
print(account?.person.name)

print(person.name)
