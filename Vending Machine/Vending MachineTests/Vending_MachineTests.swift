//
//  Vending_MachineTests.swift
//  Vending MachineTests
//
//  Created by Chris Parkinson on 6/28/20.
//  Copyright © 2020 Chris Parkinson. All rights reserved.
//

import XCTest
@testable import Vending_Machine

class Vending_MachineTests: XCTestCase {

    var vendingVC: ViewController = ViewController()
    
    func makeSUT() -> ViewController {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "VendingMachine") as! ViewController
        sut.loadViewIfNeeded()
        return sut
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vendingVC = makeSUT()
    }
    
    func testSetup(){
        XCTAssert(vendingVC.customerCoins.count == 15)
        XCTAssert(vendingVC.vendingCoins.count == 11)
        XCTAssert(vendingVC.slotOneItems.count == 3)
        XCTAssert(vendingVC.slotTwoItems.count == 3)
        XCTAssert(vendingVC.slotThreeItems.count == 3)
        
        XCTAssert(vendingVC.slotOneButton.titleLabel?.text == "Cola\n$1.00")
        XCTAssert(vendingVC.slotTwoButton.titleLabel?.text == "Chips\n$0.50")
        XCTAssert(vendingVC.slotThreeButton.titleLabel?.text == "Candy\n$0.65")
    }

    func testQuarter() {
        let startQuarter: Int = vendingVC.customerCoins.filter{$0 == vendingVC.quarter}.count
        vendingVC.spendQuarter()
        let endQuarter: Int = vendingVC.customerCoins.filter{$0 == vendingVC.quarter}.count
        XCTAssertNotEqual(startQuarter, endQuarter)
        XCTAssert(vendingVC.moneyInserted == 0.25)
    }
    
    func testDime() {
        let startDime: Int = vendingVC.customerCoins.filter{$0 == vendingVC.dime}.count
        vendingVC.spendDime()
        let endDime: Int = vendingVC.customerCoins.filter{$0 == vendingVC.dime}.count
        XCTAssertNotEqual(startDime, endDime)
        XCTAssert(vendingVC.moneyInserted == 0.10)
    }
    
    func testNickel() {
        let startNickel: Int = vendingVC.customerCoins.filter{$0 == vendingVC.nickel}.count
        vendingVC.spendNickel()
        let endNickel: Int = vendingVC.customerCoins.filter{$0 == vendingVC.nickel}.count
        XCTAssertNotEqual(startNickel, endNickel)
        XCTAssert(vendingVC.moneyInserted == 0.05)
    }
    
    func testPenny() {
        let startPenny: Int = vendingVC.customerCoins.filter{$0 == vendingVC.penny}.count
        vendingVC.spendPenny()
        let endPenny: Int = vendingVC.customerCoins.filter{$0 == vendingVC.penny}.count
        XCTAssertNotEqual(startPenny, endPenny)
        //should still be zero because pennies are rejected automatically
        XCTAssert(vendingVC.moneyInserted == 0.00)
        XCTAssert(vendingVC.returnedCoins.count == 1)
    }
    
    func testPurchaseChips(){
        vendingVC.spendQuarter()
        vendingVC.spendQuarter()
        XCTAssert(vendingVC.moneyInserted == 0.50)
        //try to purchase chips
        vendingVC.tryToPurchase(index: 1)
        XCTAssert(vendingVC.slots[1].count == 2)
    }
    
    func testPurchaseWithChange(){
        vendingVC.spendQuarter()
        vendingVC.spendQuarter()
        vendingVC.spendDime()
        vendingVC.spendNickel()
        
        XCTAssert(vendingVC.moneyInserted == 0.65)
        //try to purchase chips
        vendingVC.tryToPurchase(index: 1)
        XCTAssert(vendingVC.slots[1].count == 2)
        
        //we expect two coins returned from this transaction
        XCTAssert(vendingVC.returnedCoins.count == 2)
        
        //should return a dime and a nickel
        let dimeCheck: Int = vendingVC.returnedCoins.filter{$0 == vendingVC.dime}.count
        let nickelCheck: Int = vendingVC.returnedCoins.filter{$0 == vendingVC.nickel}.count
        
        XCTAssert(dimeCheck == 1)
        XCTAssert(nickelCheck == 1)
        
        XCTAssert(vendingVC.returnCoinsButton.titleLabel?.text == "Return Coins (2)")
        
        vendingVC.collectChange()
        
        XCTAssert(vendingVC.returnedCoins.count == 0)
    }
    
    func testExactChange(){
        vendingVC.vendingCoins.removeAll()
        vendingVC.checkExactChange()
        XCTAssert(vendingVC.exactChangeLabel.isHidden == false)
    }

}
