/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import Graph

class ActionTagTests: XCTestCase, WatchActionDelegate {
    var saveExpectation: XCTestExpectation?
    
    var tagAddExpception: XCTestExpectation?
    var tagUpdateExpception: XCTestExpectation?
    var tagRemoveExpception: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTagAdd() {
        saveExpectation = expectation(description: "[ActionTests Error: Graph save test failed.]")
        tagAddExpception = expectation(description: "[ActionTests Error: Tag add test failed.]")
        
        let graph = Graph()
        let watch = Watch<Action>(graph: graph).for(types: "T").has(tags: ["G1"]).resume()
        watch.delegate = self
        
        let action = Action(type: "T")
        action.add(tag: "G1")
        
        XCTAssertTrue(action.has(tag: "G1"))
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTagUpdate() {
        saveExpectation = expectation(description: "[ActionTests Error: Graph save test failed.]")
        
        let graph = Graph()
        
        let action = Action(type: "T")
        action.add(tag: "G2")
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        saveExpectation = expectation(description: "[ActionTests Error: Graph save test failed.]")
        tagAddExpception = expectation(description: "[ActionTests Error: Tag add test failed.]")
        tagRemoveExpception = expectation(description: "[ActionTests Error: Tag remove test failed.]")
        
        let watch = Watch<Action>(graph: graph).has(tags: ["G1", "G2"]).resume()
        watch.delegate = self
        
        action.add(tag: "G1")
        action.remove(tag: "G2")
        
        XCTAssertTrue(action.has(tag: "G1"))
        XCTAssertFalse(action.has(tag: "G2"))
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTagDelete() {
        saveExpectation = expectation(description: "[ActionTests Error: Graph save test failed.]")
        
        let graph = Graph()
        
        let action = Action(type: "T")
        action.add(tag: "G2")
        
        XCTAssertTrue(action.has(tag: "G2"))
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        saveExpectation = expectation(description: "[ActionTests Error: Graph save test failed.]")
        tagRemoveExpception = expectation(description: "[ActionTests Error: Tag remove test failed.]")
        
        let watch = Watch<Action>(graph: graph).has(tags: ["G2"]).resume()
        watch.delegate = self
        
        
        action.remove(tag: "G2")
        
        XCTAssertFalse(action.has(tag: "G2"))
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func watch(graph: Graph, action: Action, added tag: String, source: GraphSource) {
        XCTAssertTrue("T" == action.type)
        XCTAssertTrue(0 < action.id.characters.count)
        XCTAssertEqual("G1", tag)
        XCTAssertTrue(action.has(tag: tag))
        XCTAssertEqual(1, action.tags.count)
        XCTAssertTrue(action.tags.contains(tag))
        
        tagAddExpception?.fulfill()
    }
    
    func watch(graph: Graph, action: Action, removed tag: String, source: GraphSource) {
        XCTAssertTrue("T" == action.type)
        XCTAssertTrue(0 < action.id.characters.count)
        XCTAssertEqual("G2", tag)
        XCTAssertFalse(action.has(tag: tag))
        
        tagRemoveExpception?.fulfill()
    }
}
