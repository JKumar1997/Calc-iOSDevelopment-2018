//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

import Foundation

var args = ProcessInfo.processInfo.arguments
args.removeFirst() // remove the name of the program


// basic stack implementation

class Stack {
    var stack = [String]()
    // insert an item onto the top of the stack
    func push(input: String) {
        self.stack.append(input)
    }
    
    // remove an item from the top of the stack
    func pop() -> String? {
        if self.stack.last != nil {
            let lastItem = self.stack.last
            self.stack.removeLast()
            return lastItem!
        } else {
            return nil
        }
    }
    
    // get the value of the item at the top of the stack
            func top() -> String? {
                if self.stack.last != nil {
            let lastItem = self.stack.last
            return lastItem!
        } else {
            return nil
        }
    }
    
    // check if the stack is empty
    func empty() -> Bool {
        if stack.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    // get the size of the stack
    func size() -> Int {
        if stack.isEmpty {
            return 0
        } else {
            return stack.count
        }
    }
}


// class containing all the operations that will be done on the infix expression

// Naming Schemes : 3 types of expressions in computing
// 1. Infix - the type which is used in normal arithmetic. The operator comes between the operands, eg. 3 + 5
// 2. Prefix - in this, the operator comes before the operands, eg. + 3 5
// 3. Postfix - in this, the operator comes after the operands, eg. 3 5 +

// infix expressions are converted into postfix expressions using a stack which allows for easy calculation as the processing of the expression from left to right becomes easy for a computer

class InfixConverter {
    
    // dictionary to store the precedence of the oeprators
    var precedence : Dictionary<String,Int>
    
    // initialize the precedence dict in the constructor
    init() {
        precedence = [String: Int]()
        precedence["x"] = 2
        precedence["%"] = 2
        precedence["/"] = 2
        precedence["+"] = 1
        precedence["-"] = 1
    }

    
    // this function uses a stack to convert the infix expression into a postfix expression
    // a variant of the shunting yard algorithm was used to implement this with small changes to incorporate
    // negative and multi-digit numbers
    
    func convertInfixToPostfix(infix: String) -> String {
        var postfixString = String()
        let stack = Stack()
        let validator = Validator()
        
        // Iterate through every token in the expression, append the operands to the postfix expression, push the operators into the stack
        for token in infix {
            if validator.isStringNum(num: String(token)) || validator.isStringNegSymbol(op: String(token)) {
                postfixString.append(String(token))
            } else if token == " " {
                continue
            } else {
                // pop operators from the stack based on precedence and append them to the postfix expression
                postfixString += " "
                while stack.empty() == false && (precedence[stack.top()!]! >= precedence[String(token)]!) {
                    postfixString.append(stack.pop()!)
                }
                stack.push(input: String(token))
            }
        }
        
        // empty out the stack by appending the rest of the values onto the postfix expression string
        while stack.empty() == false {
            postfixString.append(stack.pop()!)
        }
        
        return " " + postfixString
    }
    
    // this function is used to separate the tokens present in the postfix expression
    // into an array made up of them
    // this is done to have an efficient structure containing negative and multidigit numbers which makes processing and calculations easier
    func getPostfixTokens(postfix: String) -> [String] {
        
        var tokens = [String]()
        let postfixString = postfix + " !"
        var currentToken = String()
        let validator = Validator()
        var flag = 0
        
        for char in postfixString {
            if char != " " {
                
                // check if the character is ~, which is the proxy for the unary minus sign which is not an operator
                // if so, change it to "-" and append it along with the number that immediately follows it
                if char == "~" {
                    flag = 1
                    currentToken = "-"
                    continue
                }
                
                
                // if the current token is a number or the previous token was a unary negative sign,
                // if the next processed token is an operator, add the previous number into the tokens array
                // and put the operator token into the current token variable
                // if the next processed token is a number, this means that it is a multi-digit number so we just append it along with the previous number
                if validator.isStringNum(num: currentToken) || flag == 1 {
                   
                    if validator.isStringOp(op: String(char)) {
                        tokens.append(currentToken)
                        currentToken = String(char)
                    } else {
                        currentToken += String(char)
                    }
                    
                    if flag == 1 {
                        flag = 0
                    }
                // if the current token is an operator, just add it to the list of tokens since we've already handled the unary negative case,
                // and set the current token to the current processed token
                } else if validator.isStringOp(op: currentToken) {
                    
                    tokens.append(currentToken)
                    currentToken = String(char)
                // if the current token is empty, check if the processed token is an operator. if so, add it to the list of tokens
                // if not, add it to the current token variable
                } else if currentToken.isEmpty {
                    if validator.isStringOp(op: String(char)) {
                        tokens.append(String(char))
                    } else {
                        currentToken = String(char)
                    }
                }
                
            // ! is added to the end of the postfix expression to serve as a delimiter since " " is used to separate different values in the expression itself
            } else if char == "!" && tokens.isEmpty {
                tokens.append(currentToken)
                return tokens
            } else {
                if !currentToken.isEmpty {
                    tokens.append(currentToken)
                    currentToken = ""
                }
                
            }
        }
        
        return tokens
    }
}



// this class is used to perform all the required operations on the postfix expression tokens that are received from the infix expression processing

class PostfixProcessor {
    var result: Int
    
    //simple function that uses a stack to store the tokens present in the token array
    // and perform postfix expression evaluation
    init(postfixString: [String]) {
        let stack = Stack()
        let maths = Maths()
        result = Int()
        let validator = Validator()
        var operand1 = Int()
        var operand2 = Int()
    
        for string in postfixString {
            
            if validator.isStringNum(num: string) {
                stack.push(input: string)
            } else if validator.isStringOp(op: string) && stack.empty() == false{
                if stack.size() > 1 {
                    operand2 = Int(stack.pop()!)!
                    operand1 = Int(stack.pop()!)!
                    result = maths.calculate(op: string, number1: operand1, number2: operand2)
                    stack.push(input: String(result))
                }
            }
        }
       
        if stack.empty() == false {
            result = Int(stack.top()!)!
        }
     
        
        
    }
    
    // returns the result variable
    func getResult() -> Int {
        return result
    }
}

// this class is used to perform mathematical operations
class Maths {
    
    // function that takes an operator and two operands as parameters
    // and performs a relevant calculation and returns the result
    func calculate(op: String, number1: Int, number2: Int) -> Int {
        switch op {
        case "+":
            return number1 + number2
        case "-":
            return number1 - number2
        case "x":
            return number1 * number2
        case "/":
            return number1 / number2
        case "%":
            return number1 % number2
            
        default:
            return 0
        }
    }
}



// trhis class is used to perform validations on any value
class Validator {
    
    // check if the string can be converted into or is in the form of an integer
    func isStringNum(num: String) -> Bool {
        return Int(num) != nil
    }
    
    // check if the string is a space
    func isStringSpace(string: String) -> Bool {
        return string == " "
    }
    
    // check if the string is an oeprator
    func isStringOp(op: String) -> Bool {
        switch op {
        case "+", "-", "/", "x", "%":
            return true
        default:
            return false
        }
    }
    // check if the string is the unary negative operator set by us
    func isStringNegSymbol(op: String) -> Bool {
        return op == "~"
    }
}


// perform preliminary validations to ensure that the input is valid and can be processed
let validator = Validator()
var numOperands = 0
var numOperators = 0
for string in args {
    // check for invalid tokens
    if !validator.isStringNum(num: string) && !validator.isStringOp(op: string) {
        exit(1)
    }
    if validator.isStringNum(num: string) {
        numOperands += 1
    }
    if validator.isStringOp(op: string) {
        numOperators += 1
    }
    
}
// check for mismatched number of operators and operands
if numOperands != numOperators + 1 {
    exit(1)
}
// create a whole string from the array of arguments
var expression = args.joined(separator: " ")
// use regex to replace all occurrences of unary negative signs with "~"
expression = expression.replacingOccurrences(of: "(-)([0-9])", with: " ~$2", options: NSString.CompareOptions.regularExpression, range: nil)

// perform all the relevant calculations
let converted = InfixConverter()
let convertedResult = converted.convertInfixToPostfix(infix: expression)
let processor = PostfixProcessor(postfixString: converted.getPostfixTokens(postfix: convertedResult))
// display the result
print(processor.getResult())


