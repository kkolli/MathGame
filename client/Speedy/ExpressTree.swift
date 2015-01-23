//
//  ExpressTree.swift
//  Speedy
//
//  Created by Edward Chiou on 1/22/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

enum ExpressionNodeType {
    case Operator
    case Operand
}

class ExpressionNode{
    var leftOperand: ExpressionNode?
    var rightOperand: ExpressionNode?
    var childOperator: ExpressionNode?
    var type: ExpressionNodeType?
    var value: String? = nil
}

class ExpressionTree{
    var root: ExpressionNode? = nil
    
    init(root: ExpressionNode){
        self.root = root
    }
    
    func addNode(node: ExpressionNode){
        if(root == nil){
            if(node.type == ExpressionNodeType.Operand){
                self.root = node
            }else{
                //Error condition
            }
        }else{
            
        }
    }
}