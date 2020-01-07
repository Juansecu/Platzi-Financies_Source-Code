import Foundation

func Sum<GN: Numeric>(a: GN, b: GN) -> GN {
    return a + b
}

Sum(a: 1.8, b: 5)

class Stack<Element> {
    var items: [Element] = []
    
    func push(_ item: Element) {
        items.append(item)
    }
    
    func pop() -> Element {
        return items.removeLast()
    }
}

var stack = Stack<Int>()

stack.push(2)
stack.push(3)
stack.push(7)
stack.push(1)

stack.pop()

print(stack.items)

var stack2 = Stack<String>()

stack2.push("Sebastian")
stack2.push("Cuello")

stack2.pop()

print(stack2.items)
