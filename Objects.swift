//
//  Objects.swift
//  GraphTheory Shared
//
//  Created by Luke M on 4/9/19.
//  Copyright © 2019 Luke M. All rights reserved.
//

import Foundation
import SpriteKit

func midpoint(p1: CGPoint, p2: CGPoint) -> CGPoint
{
    return CGPoint(x: ((p1.x + p2.x)/2), y: ((p1.y + p2.y)/2))
}

class Graph
{
    var name: String
    
    var vertices = [Vertex]()
    var edges = [Edge]()
    
    //Counts include since removed objects
    var vertexCount = 0
    var edgeCount = 0
    
    var directed: Bool
    var weighted: Bool
    var allowSelfLoops: Bool
    
    let parent: SKScene
    
    init(name: String, directed: Bool, weighted: Bool, allowSelfLoops: Bool, parent: SKScene)
    {
        self.name = name
        self.directed = directed
        self.weighted  = weighted
        self.allowSelfLoops = allowSelfLoops
        self.parent = parent
    }
    
    func addVertex(pos: CGPoint, sColor: SKColor = SKColor.white, fColor: SKColor = SKColor.white, name: String = "") -> Vertex
    {
        vertexCount += 1
        vertices.append(Vertex(id: vertexCount, pos: pos, name: name, sColor: sColor, fColor: fColor))
        return vertices[vertices.count-1]
    }
    
    func getVertex(id: Int) -> Vertex?
    {
        for v in vertices
        {
            if v.id == id
            {
                return v
            }
        }
        return nil
    }
    
    func removeVertex(id: Int)
    {
        for i in 0...vertices.count
        {
            if vertices[i].id == id
            {
                vertices[i].undraw()
                for e in edges
                {
                    if vertices[i].id == e.vertices.0.id || vertices[i].id == e.vertices.1.id
                    {
                        removeEdge(id: e.id)
                    }
                }
                vertices.remove(at: i)
                break
            }
        }
    }
    
    func findVertexEdges(v: Vertex) -> [Edge]
    {
        var foundEdges = [Edge]()
        for e in edges
        {
            if e.vertices.0.id == v.id || e.vertices.1.id == v.id
            {
                foundEdges.append(e)
            }
        }
        return foundEdges
    }
    
    func addEdge(vertices: (Vertex, Vertex), weight: Double? = nil, name: String = "") -> Edge
    {
        edgeCount += 1
        edges.append(Edge(id: edgeCount, vertices: vertices, name: name, directed: self.directed, weight: weight))
        vertices.0.degree += 1
        vertices.1.degree += 1
        return edges[edges.count-1]
    }
    
    func getEdge(id: Int) -> Edge?
    {
        for e in edges
        {
            if e.id == id
            {
                return e
            }
        }
        return nil
    }
    
    func removeEdge(id: Int)
    {
        for i in 0...edges.count
        {
            if edges[i].id == id
            {
                edges[i].undraw()
                edges[i].vertices.0.degree -= 1
                edges[i].vertices.1.degree -= 1
                edges.remove(at: i)
                break
            }
        }
    }
    
    func toString() -> String
    {
        var s = "---Graph---\n"
        for v in vertices
        {
            s += v.toString()
        }
        for e in edges
        {
            s += e.toString()
        }
        return s
    }
    
    func getShapes() -> [SKNode]
    {
        var shapes = [SKNode]()
        for v in vertices
        {
            shapes.append(v.getShape())
            shapes.append(v.getLabel())
        }
        for e in edges
        {
            shapes.append(e.getShape())
            shapes.append(e.getLabel())
        }
        return shapes
    }
    
    func resetColor()
    {
        for v in vertices
        {
            v.color(sColor: v.strokeColor, fColor: v.fillColor)
        }
        for e in edges
        {
            e.color(sColor: e.strokeColor)
        }
    }
}

class Part
{
    let id: Int
    var label: SKLabelNode
    var shape: SKShapeNode
    var name: String
    var strokeColor: SKColor
    
    init(id: Int, shape: SKShapeNode, name: String = "", sColor: SKColor = SKColor.white)
    {
        self.id = id
        self.label = SKLabelNode(text: String(id))
        self.label.fontSize = 32
        self.label.fontColor = NSColor.red
        self.shape = shape
        self.name = name
        self.strokeColor = sColor
    }
    
    func toString() -> String
    {
        var s = ""
        s += "id: \(self.id)\n"
        if name != ""
        {
            s += "name: \(self.name)\n"
        }
        return s
    }
    
    func color(sColor: SKColor)
    {
        self.shape.strokeColor = sColor
    }
    
    func getShape() -> SKShapeNode
    {
        return self.shape
    }
    
    func getLabel() -> SKLabelNode
    {
        self.label.position = self.shape.position
        return self.label
    }
    
    func undraw()
    {
        self.shape.removeFromParent()
        self.label.removeFromParent()
    }
}

class Vertex: Part
{
    var degree: Int = 0
    var fillColor: SKColor
    
    init(id: Int, pos: CGPoint, name: String = "", sColor: SKColor = SKColor.white, fColor: SKColor = SKColor.white)
    {
        self.fillColor = fColor
        super.init(id: id, shape: SKShapeNode(circleOfRadius: 15), name: name, sColor: sColor)
        self.shape.position = pos
        self.label.position = pos
        self.shape.name = "v\(id)"
    }
    
    override func toString() -> String
    {
        var s = "Vertex:\n"
        s += super.toString()
        return s
    }
    
    func color(sColor: SKColor, fColor: SKColor)
    {
        self.shape.strokeColor = sColor
        self.shape.fillColor = fColor
    }
}

class Edge: Part
{
    var vertices: (Vertex, Vertex)
    
    var directed: Bool
    var weighted: Bool
    var weight = 0.0
    
    init(id: Int, vertices: (Vertex, Vertex), name: String = "", sColor: SKColor = SKColor.white, directed: Bool = false, weight: Double? = nil)
    {
        self.vertices = vertices
        self.directed = directed
        if weight != nil
        {
            self.weighted = true
            self.weight = weight!
        }
        else
        {
            self.weighted = false
        }
        super.init(id: id, shape: SKShapeNode(), name: name, sColor: sColor)
        self.shape.name = "e\(self.id)"
        self.label.position = midpoint(p1: self.vertices.0.shape.position, p2: self.vertices.1.shape.position)
    }
    
    override func toString() -> String
    {
        var s = "Edge:\n"
        s += super.toString()
        s += "Path: \(vertices.0.id)"
        if directed
        {
            s += " -> "
        }
        else
        {
            s += " -- "
        }
        s += "\(vertices.1.id)\n"
        if weighted
        {
            s += "weight: \(weight)\n"
        }
        return s
    }
    
    override func getShape() -> SKShapeNode
    {
        let path = CGMutablePath()
        path.move(to: self.vertices.0.shape.position)
        path.addLine(to: self.vertices.1.shape.position)
        self.shape.path = path
        self.shape.fillColor = self.strokeColor
        return self.shape
    }
    
    override func getLabel() -> SKLabelNode
    {
        self.label.position = midpoint(p1: self.vertices.0.shape.position, p2: self.vertices.1.shape.position)
        return self.label
    }
}
