//
//  GameScene.swift
//  GraphTheory
//
//  Created by Luke M on 4/13/19.
//  Copyright © 2019 Luke M. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var modeLabel: SKLabelNode?
    private var dataLabel: SKLabelNode?
    
    private var activeGraph: Graph?
    private var selection: Part?
    private var clickPoints: (Part?, Part?)
    private var inputMode = "euler" // "modify", "manipulate", "view", "euler"
    private var animationQueue = [Part]()
    
    func drawGraph(graph: Graph)
    {
        let shapes = graph.getShapes()
        for s in shapes
        {
            self.addChild(s)
        }
    }
    
    func undrawGraph(graph: Graph)
    {
        let shapes = graph.getShapes()
        for s in shapes
        {
            s.removeFromParent()
        }
    }
    
    // Input Processing
    func changeInputMode(mode: String)
    {
        self.inputMode = mode
        self.modeLabel!.text = "Mode: " + mode
    }
    
    func select(type: String, id: Int)
    {
        if let s: Part = selection
            {
                s.color(sColor: s.strokeColor)
            }
        if type ==  "v"
        {
            selection = activeGraph?.getVertex(id: id)
        }
        else if type == "e"
        {
            selection = activeGraph?.getEdge(id: id)
        }
        
        selection!.color(sColor: SKColor.red)
    }
    
    func calcSelect(touchedNodes: [SKNode])
    {
        var touchedEdges = [Int]()
        var touchedVertices = [Int]()
        
        for n in touchedNodes
        {
            if n.name != nil
            {
                var name = n.name!
                name.remove(at: name.startIndex)
                let id = Int(name)!
                if n.name!.hasPrefix("v")
                {
                    touchedVertices.append(id)
                }
                else if n.name!.hasPrefix("e")
                {
                    touchedEdges.append(id)
                }
            }
        }
        if touchedVertices.count >= 1
        {
            select(type: "v", id: touchedVertices[0])
        }
        else if touchedEdges.count >= 1
        {
            select(type: "e", id: touchedEdges[0])
        }
        else
        {
            if let s: Part = selection
            {
                s.color(sColor: s.strokeColor)
            }
            selection = nil
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Label Node Setup
        self.label = SKLabelNode(text: "MATH 307 - Spring 2019 - Luke McGuire")
        self.label!.fontName = "times new roman"
        self.label!.fontSize = 16
        self.label!.position = CGPoint(x: -self.size.width/3, y: -self.size.height/2.05)
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        self.addChild(self.label!)
        
        self.modeLabel = SKLabelNode(text: "Mode: " + self.inputMode)
        self.modeLabel!.fontName = "times new roman"
        self.modeLabel!.fontSize = 16
        self.modeLabel!.position = CGPoint(x: -self.size.width/2.25, y: self.size.height/2.1)
        self.addChild(self.modeLabel!)
        
        self.dataLabel = SKLabelNode()
        self.dataLabel!.position = CGPoint(x: self.size.width/4, y: self.size.height/3)
        self.dataLabel!.fontName = "times new roman"
        self.dataLabel!.fontSize = 16
        self.dataLabel!.numberOfLines = 3
        
        //Default Graph Setup
        activeGraph = Graph(name: "test", directed: false, weighted: false, allowSelfLoops: false, parent: self)
        let v1 = activeGraph?.addVertex(pos: CGPoint(x: -50, y: 50))
        let v2 = activeGraph?.addVertex(pos: CGPoint(x: 50, y: 50))
        _ = activeGraph?.addEdge(vertices: (v1!, v2!))
        let v3 = activeGraph?.addVertex(pos: CGPoint(x: -50, y: -50))
        let v4 = activeGraph?.addVertex(pos: CGPoint(x: 50, y: -50))
        _ = activeGraph?.addEdge(vertices: (v3!, v4!))
        _ = activeGraph?.addEdge(vertices: (v1!, v3!))
        _ = activeGraph?.addEdge(vertices: (v2!, v4!))
        let v5 = activeGraph?.addVertex(pos: CGPoint(x: 0, y: -125))
        let v6 = activeGraph?.addVertex(pos: CGPoint(x: -125, y: 0))
        let v7 = activeGraph?.addVertex(pos: CGPoint(x: 0, y: 125))
        let v8 = activeGraph?.addVertex(pos: CGPoint(x: 125, y: 0))
        _ = activeGraph?.addEdge(vertices: (v7!, v1!))
        _ = activeGraph?.addEdge(vertices: (v7!, v2!))
        _ = activeGraph?.addEdge(vertices: (v8!, v4!))
        _ = activeGraph?.addEdge(vertices: (v8!, v2!))
        _ = activeGraph?.addEdge(vertices: (v6!, v1!))
        _ = activeGraph?.addEdge(vertices: (v6!, v3!))
        _ = activeGraph?.addEdge(vertices: (v5!, v3!))
        _ = activeGraph?.addEdge(vertices: (v5!, v4!))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        calcSelect(touchedNodes: self.nodes(at: pos))
        clickPoints.0 = selection
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if inputMode == "manipulate" && selection is Vertex
        {
            let v = selection as! Vertex
            v.shape.position = pos
            
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        calcSelect(touchedNodes: self.nodes(at: pos))
        clickPoints.1 = selection
        if inputMode == "view"
        {
        
        }
        else if inputMode == "modify"
        {
            if selection == nil
            {
                _ = activeGraph?.addVertex(pos: pos)
            }
            else if clickPoints.0 is Vertex && clickPoints.1 is Vertex
            {
                let vertices: (Vertex, Vertex) = clickPoints as! (Vertex, Vertex)
                if activeGraph!.allowSelfLoops || vertices.0.id != vertices.1.id
                {
                    
                    _ = activeGraph?.addEdge(vertices: vertices)
                }
            }
        }
        else if inputMode == "euler"
        {
            if selection is Vertex
            {
                let result = Hierholzer(graph: activeGraph!, start: selection as! Vertex)
                dataLabel!.text = result.1
                dataLabel!.position = CGPoint(x: self.size.width/4, y: self.size.height/3)
                dataLabel!.removeFromParent()
                self.addChild(dataLabel!)
                print(result.1)
                var p = ""
                for v in result.0.vertexTour
                {
                    p += "-\(v.id)"
                }
                animationQueue += result.0.edgeTour
            }
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31: //Space
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        case 0x33: //Delete
            if selection != nil && inputMode == "modify"
            {
                if selection is Vertex
                {
                    activeGraph?.removeVertex(id: selection!.id)
                }
                else if selection is Edge
                {
                    activeGraph?.removeEdge(id: selection!.id)
                }
            }
        case 0x2E: //m (modify mode)
            changeInputMode(mode: "modify")
        case 0x01: //s (manipulate mode)
            changeInputMode(mode: "manipulate")
        case 0x09: //v (view mode)
            changeInputMode(mode: "view")
        case 0x0E: //e (euler)
            changeInputMode(mode: "euler")
        case 0x0F: //r (reset activeGraph coloring)
            activeGraph?.resetColor()
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let _ = self.activeGraph
        {
            undrawGraph(graph: activeGraph!)
            drawGraph(graph: activeGraph!)
        }
        
        if inputMode == "view" && selection != nil
        {
            dataLabel!.text = selection!.toString()
            dataLabel!.position = CGPoint(x: -self.size.width/2.75, y: self.size.height/2.4)
            dataLabel!.removeFromParent()
            self.addChild(dataLabel!)
        }
        else if inputMode != "view" && inputMode != "euler"
        {
            dataLabel!.removeFromParent()
        }
        
        if animationQueue.count > 0
        {
            animationQueue[0].color(sColor: SKColor.blue)
            animationQueue.remove(at: 0)
            sleep(1)
        }
    }
}
