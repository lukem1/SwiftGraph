//
//  Algorithms.swift
//  GraphTheory
//
//  Created by Luke M on 4/16/19.
//  Copyright © 2019 Luke M. All rights reserved.
//

import Foundation
import SpriteKit

struct Tour
{
    var vertexTour = [Vertex]()
    var edgeTour = [Edge]()
    
    mutating func add(vertex: Vertex, edge: Edge)
    {
        vertexTour.append(vertex)
        edgeTour.append(edge)
    }
    
    mutating func integrateSubtour(subtour: Tour)
    {
        var integratedTour = Tour()
        
        if subtour.isCycle()
        {
            if vertexTour.count == 0
            {
                integratedTour.vertexTour += subtour.vertexTour
                integratedTour.edgeTour += subtour.edgeTour
            }
            else
            {
                for i in 0...vertexTour.count-1
                {
                    if vertexTour[i].id == subtour.vertexTour[0].id
                    {
                        integratedTour.vertexTour += subtour.vertexTour
                        integratedTour.edgeTour += subtour.edgeTour
                        
                        for l in i+1...vertexTour.count-1
                        {
                            integratedTour.add(vertex: vertexTour[l], edge: edgeTour[l-1])
                        }
                        break
                    }
                    else
                    {
                        integratedTour.add(vertex: vertexTour[i], edge: edgeTour[i])
                    }
                }
            }
        }
        else
        {
            if vertexTour.count == 0
            {
                integratedTour.vertexTour += subtour.vertexTour
                integratedTour.edgeTour += subtour.edgeTour
            }
            else if vertexTour[vertexTour.count-1].id == subtour.vertexTour[0].id
            {
                integratedTour.vertexTour = vertexTour
                integratedTour.edgeTour = edgeTour
                for i in 1...subtour.vertexTour.count-1
                {
                    integratedTour.vertexTour.append(subtour.vertexTour[i])
                }
                integratedTour.edgeTour += subtour.edgeTour
            }
            else if vertexTour[0].id == subtour.vertexTour[subtour.vertexTour.count-1].id
            {
                integratedTour.vertexTour = subtour.vertexTour
                integratedTour.edgeTour = subtour.edgeTour
                for i in 1...vertexTour.count-1
                {
                    integratedTour.vertexTour.append(vertexTour[i])
                }
                integratedTour.edgeTour += edgeTour
            }
            else
            {
                print("error: unhandled path conditions")
            }
        }
        
        self = integratedTour
    }
    
    func isCycle() -> Bool
    {
        if vertexTour.count > 2 && vertexTour[0].id == vertexTour[vertexTour.count-1].id
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func toString() -> String
    {
        var str = "--Tour--"
        str += "\nEdge Tour: "
        for e in edgeTour
        {
            str += "->\(e.id)"
        }
        str += "\nVertex Tour: "
        for v in vertexTour
        {
            str += "->\(v.id)"
        }
        str += "\n"
        
        return str
    }
}

func Hierholzer(graph: Graph, start: Vertex? = nil) -> (Tour, String)
{
    var tour = Tour()
    var remainingEdges = graph.edges
    var startVertex: Vertex
    var message = "Hierholzer Algorithm Results:"
    
    //Validate Graph
    var oddVertices = [Vertex]()
    for v in graph.vertices
    {
        if v.degree % 2 != 0
        {
            oddVertices.append(v)
        }
    }
    
    //Find Euler Cycle or Path
    if remainingEdges.count > 0
    {
        if oddVertices.count == 0
        {
            message += "\nEuler Cycle"
            if start != nil
            {
                startVertex = start!
            }
            else
            {
                startVertex = graph.vertices[0]
            }
        }
        else if oddVertices.count == 2
        {
            message += "\nEuler Path\n(Note: May begin from unclicked vertex)"
            if start != nil
            {
                if oddVertices[0].id == start!.id || oddVertices[1].id == start!.id
                {
                    startVertex = start!
                }
                else
                {
                    startVertex = oddVertices[0]
                }
            }
            else
            {
                startVertex = oddVertices[0]
            }
        }
        else
        {
            message += "\nInvalid Graph"
            return (tour, message)
        }
        
        while remainingEdges.count > 0
        {
            var subtour = Tour()
            var currentVertex = startVertex
            subtour.vertexTour.append(startVertex)
            repeat
            {
                let possibleNextEdges = graph.findVertexEdges(v: currentVertex)
                var validNextEdges = [Edge]()
                for e in possibleNextEdges
                {
                    for r in remainingEdges
                    {
                        if e.id == r.id
                        {
                            validNextEdges.append(e)
                        }
                    }
                }
                if validNextEdges.count != 0
                {
                    let nextEdge = validNextEdges[0]
                    for i in 0...remainingEdges.count-1
                    {
                        if nextEdge.id == remainingEdges[i].id
                        {
                            remainingEdges.remove(at: i)
                            break
                        }
                    }
                    if nextEdge.vertices.0.id == currentVertex.id
                    {
                        currentVertex = nextEdge.vertices.1
                    }
                    else
                    {
                        currentVertex = nextEdge.vertices.0
                    }
                    subtour.vertexTour.append(currentVertex)
                    subtour.edgeTour.append(validNextEdges[0])
                }
                else //path
                {
                    break
                }
            } while currentVertex.id != startVertex.id
            //print("--Pre--")
            //print(tour.toString())
            //print(subtour.toString())
            tour.integrateSubtour(subtour: subtour)
            //print("--Post--")
            //print(tour.toString())
            var possibleVertices = [Vertex]()
            for r in remainingEdges
            {
                for v in tour.vertexTour
                {
                    if r.vertices.0.id == v.id || r.vertices.1.id == v.id
                    {
                        possibleVertices.append(v)
                    }
                }
            }
            if possibleVertices.count > 0
            {
                startVertex = possibleVertices[0]
            }
        }
    }
    else
    {
        message += "\nInvalid Graph"
    }
    message += "\n"
    message += tour.toString()
    return (tour, message)
}
