//
//  ViewController.swift
//  Vending Machine
//
//  Created by Chris Parkinson on 6/28/20.
//  Copyright © 2020 Chris Parkinson. All rights reserved.
//

import UIKit

//Equatable class to use for coin comparisons when being introduced to the machine
class Coin : Equatable {
    static func == (lhs: Coin, rhs: Coin) -> Bool {
        let areEqual = lhs.weight == rhs.weight &&
            lhs.size == rhs.size &&
            lhs.name == rhs.name
        return areEqual
    }
    
    var weight: Float
    var size: Float
    var name: String
    
    init(weight: Float, size: Float, name: String){
        self.weight = weight
        self.size = size
        self.name = name
    }
}

//class to describe a vending machine item like cola, chip, candy, etc
class VendingItem {
    var name: String
    var price: Double
    
    init(name: String, price:Double){
        self.name = name
        self.price = price
    }
}


class ViewController: UIViewController {
    //
    @IBOutlet weak var vendingMessageLabel: UILabel!
    @IBOutlet weak var exactChangeLabel: UILabel!
    @IBOutlet weak var slotOneButton: UIButton!
    @IBOutlet weak var slotTwoButton: UIButton!
    @IBOutlet weak var slotThreeButton: UIButton!
    
    @IBOutlet weak var quarterButton: UIButton!
    @IBOutlet weak var dimeButton: UIButton!
    @IBOutlet weak var nickelButton: UIButton!
    @IBOutlet weak var pennyButton: UIButton!
    
    @IBOutlet weak var returnCoinsButton: UIButton!
    
    
    let defaultMessage: String = "INSERT COIN"
    let currencyFormatter: NumberFormatter = NumberFormatter()
    
    var customerCoins:[Coin] = [Coin]()
    var vendingCoins:[Coin] = [Coin]()
    
    var insertedCoins:[Coin] = [Coin]()
    var returnedCoins:[Coin] = [Coin]()
    
    //possible vending machine items
    let cola = VendingItem(name: "Cola", price: 1.00)
    let chips = VendingItem(name: "Chips", price: 0.50)
    let candy = VendingItem(name: "Candy", price: 0.65)
    
    //possible coin items
    let quarter = Coin(weight: 5.67, size: 0.955, name: "quarter")
    let dime = Coin(weight: 2.268, size: 0.705, name: "quarter")
    let nickel = Coin(weight: 5.0, size: 0.835, name: "quarter")
    let penny = Coin(weight: 2.5, size: 0.75, name: "quarter")
    
    //slot arrays to contain vending items
    var slotOneItems:[VendingItem] = [VendingItem]()
    var slotTwoItems:[VendingItem] = [VendingItem]()
    var slotThreeItems:[VendingItem] = [VendingItem]()
    
    var slots:[[VendingItem]] = [[VendingItem]]()
    
    var moneyInserted: Double = 0.0

    
    enum CoinType {
        case quarter
        case dime
        case nickel
    }
    
    override func viewDidLoad() {
        exactChangeLabel.isHidden = true
        
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        vendingMessageLabel.text = defaultMessage;
        fillVendingMachine()
        assignVendingChange()
        assignCustomerMoney()
        checkExactChange()
    }
    
    //initialize the vending machine with items for purchase
    func fillVendingMachine(){
        slotOneItems = [cola, cola, cola]
        slotTwoItems = [chips, chips, chips]
        slotThreeItems = [candy, candy, candy]
        
        slots = [slotOneItems, slotTwoItems, slotThreeItems]
        
        let slotOneLabel: String = slotOneItems[0].name + "\n" + currencyFormatter.string(from: NSNumber(value: slotOneItems[0].price))!
        slotOneButton.setTitle(slotOneLabel, for: .normal)
        slotOneButton.titleLabel?.textAlignment = .center
        
        let slotTwoLabel: String = slotTwoItems[0].name + "\n" + currencyFormatter.string(from: NSNumber(value: slotTwoItems[0].price))!
        slotTwoItems = [chips, chips, chips]
        slotTwoButton.setTitle(slotTwoLabel, for: .normal)
        slotTwoButton.titleLabel?.textAlignment = .center
        
        let slotThreeLabel: String = slotThreeItems[0].name + "\n" + currencyFormatter.string(from: NSNumber(value: slotThreeItems[0].price))!
        slotThreeItems = [candy, candy, candy]
        slotThreeButton.setTitle(slotThreeLabel, for: .normal)
        slotThreeButton.titleLabel?.textAlignment = .center
    }
    
    @IBAction func slotOneSelected(_ sender: Any) {
        tryToPurchase(index: 0)
    }
    
    @IBAction func slotTwoSelected(_ sender: Any) {
        tryToPurchase(index: 1)
    }
    
    @IBAction func slotThreeSelected(_ sender: Any) {
        tryToPurchase(index: 2)
    }
    
    //attampt to make a purchase based on selected slot index
    func tryToPurchase(index: Int){
        let roundedMoney = round(1000.0 * moneyInserted) / 1000.0
        if(slots[index][0].price <= roundedMoney){
            //alert the user that their purchase was successful
            let alertController = UIAlertController(title: "THANK YOU!", message: "Please collect your " + slots[index][0].name, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "COLLECT", style: .default)
            alertController.addAction(alertAction)
            present(alertController, animated: true)
            
            let priceDifference: Double = moneyInserted - slots[index][0].price
            slots[index].removeFirst()
            vendingCoins.append(contentsOf: insertedCoins)
            insertedCoins.removeAll()
            
            //make change if customer inserted more money than the price of the item
            if(priceDifference > 0){
                makeChange(change: priceDifference)
            }
            
            //if this was the last item purchased for this slot we sell out of it
            if(slots[index].count == 0){
                sellOut(index: index)
            }
            
            //reset money values
            moneyInserted = 0.0
            updateTotal(coinValue: 0)
            
            //see if we have enough change for the next time we want to purchase
            checkExactChange()
        }
        else{
            //show an alert that we need more funds and show how much a customer has contributed
           let alertController = UIAlertController(title: "More Funds Needed!", message: "This item is " + currencyFormatter.string(from: NSNumber(value: slots[index][0].price))! + " and you have only inserted " + currencyFormatter.string(from: NSNumber(value: moneyInserted))!, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(alertAction)
            present(alertController, animated: true)
        }
    }
    
    //disable specific slots if a certain item sells out
    func sellOut(index: Int){
        switch(index){
        case 0:
            slotOneButton.isEnabled = false
            slotOneButton.setTitle("SOLD OUT", for: .normal)
            break
        case 1:
            slotTwoButton.isEnabled = false
            slotTwoButton.setTitle("SOLD OUT", for: .normal)
            break
        case 2:
            slotThreeButton.isEnabled = false
            slotThreeButton.setTitle("SOLD OUT", for: .normal)
            break
        default:
            break
        }
    }
    
    //checks how much change to return and which coins to use using "greedy" method
    func makeChange(change: Double){
        //if we already warned about exact change we keep the change and dont attempt to distribute
        if(!exactChangeLabel.isHidden){return}
        
        var changeNeeded: Double = round(1000.0 * change) / 1000.0
        
        //start with quarters
        let usableQuarters = (changeNeeded / 0.25).rounded(.towardZero)
        //changeNeeded.truncatingRemainder(dividingBy: 0.25)
        if(usableQuarters >= 1){
            for _ in 1...Int(usableQuarters) {
                if let index = vendingCoins.firstIndex(of: quarter) {
                    returnedCoins.append(vendingCoins[index])
                    vendingCoins.remove(at: index)
                    changeNeeded -= 0.25
                }
            }
        }
        //double check change to make sure we get a value we can easily work with
        changeNeeded = round(1000.0 * changeNeeded) / 1000.0
       
        //then dimes
        let usableDimes = (changeNeeded / 0.10).rounded(.towardZero)
        if(usableDimes >= 1)
        {
            for _ in 1...Int(usableDimes) {
                if let index = vendingCoins.firstIndex(of: dime) {
                    returnedCoins.append(vendingCoins[index])
                    vendingCoins.remove(at: index)
                    changeNeeded -= 0.10
                }
            }
        }
        //double check change to make sure we get a value we can easily work with
        changeNeeded = round(1000.0 * changeNeeded) / 1000.0

        //then nickels
        let usableNickels = (changeNeeded / 0.05).rounded(.towardZero)
        if(usableNickels >= 1){
            for _ in 1...Int(usableNickels) {
                if let index = vendingCoins.firstIndex(of: nickel) {
                    returnedCoins.append(vendingCoins[index])
                    vendingCoins.remove(at: index)
                    changeNeeded -= 0.05
                }
            }
        }

        updateReturnedLabel()
    }
    
    //grant customer some coins at start
    func assignCustomerMoney(){
        customerCoins = [quarter, quarter, quarter, quarter, quarter, quarter, dime, dime, dime, nickel, nickel, nickel, penny, penny, penny]
        updateCoinCount()
    }
    
    //grant vending machine some coins at start for change
    func assignVendingChange(){
        vendingCoins = [quarter, quarter, quarter, quarter, dime, nickel, nickel, nickel, penny, penny, penny]
    }
    
    @IBAction func insertQuarter(_ sender: Any) {
        spendQuarter()
    }
    
    func spendQuarter(){
        if let index = customerCoins.firstIndex(of: quarter) {
            checkCoin(insertedCoin: customerCoins[index])
            customerCoins.remove(at: index)
            updateCoinCount()
        }
    }
    
    @IBAction func insertDime(_ sender: Any) {
        spendDime()
    }
    
    func spendDime(){
        if let index = customerCoins.firstIndex(of: dime) {
            checkCoin(insertedCoin: customerCoins[index])
            customerCoins.remove(at: index)
            updateCoinCount()
        }
    }
    
    @IBAction func insertNickel(_ sender: Any) {
        spendNickel()
    }
    
    func spendNickel(){
        if let index = customerCoins.firstIndex(of: nickel) {
            checkCoin(insertedCoin: customerCoins[index])
            customerCoins.remove(at: index)
            updateCoinCount()
        }
    }
    
    @IBAction func insertPenny(_ sender: Any) {
        spendPenny()
    }
    
    func spendPenny(){
        if let index = customerCoins.firstIndex(of: penny) {
            checkCoin(insertedCoin: customerCoins[index])
            customerCoins.remove(at: index)
            updateCoinCount()
        }
    }
    
    @IBAction func collectChangeButtonPressed(_ sender: Any) {
        collectChange()
    }
    
    @IBAction func returnCoinsButtonPressed(_ sender: Any) {
        returnCoins()
    }
    
    //update values of coins based on how many coins the customer still has
    func updateCoinCount(){
        let quarterCount: Int = customerCoins.filter{$0 == quarter}.count
        let dimeCount: Int = customerCoins.filter{$0 == dime}.count
        let nickelCount: Int = customerCoins.filter{$0 == nickel}.count
        let pennyCount: Int = customerCoins.filter{$0 == penny}.count
        
        quarterButton.setTitle("Quarter(" + String(quarterCount) + ")", for: .normal)
        dimeButton.setTitle("Dime(" + String(dimeCount) + ")", for: .normal)
        nickelButton.setTitle("Nickel(" + String(nickelCount) + ")", for: .normal)
        pennyButton.setTitle("Penny(" + String(pennyCount) + ")", for: .normal)
    }
    
    //check if we at least have a nickel and a dime... anything beyond this and we should be able to use the customer coins to give change
    func checkExactChange(){
        if(vendingCoins.contains(dime) == true && vendingCoins.contains(nickel) == true)
        {
            exactChangeLabel.isHidden = true
        }
        else
        {
            exactChangeLabel.isHidden = false
        }
    }
    
    //validate inserted coins based on real world measurements of US coins
    func checkCoin(insertedCoin: Coin){
        switch(insertedCoin.weight){
        case 5.67:
            //quarter check
            if(insertedCoin.size == 0.955){
                addCoinToTotal(coin: insertedCoin, type: .quarter)
            }
            else{
                rejectCoin(coin: insertedCoin)
            }
            break;
        case 2.268:
            //dime check
            if(insertedCoin.size == 0.705){
                addCoinToTotal(coin: insertedCoin, type: .dime)
            }
            else{
                rejectCoin(coin: insertedCoin)
            }
            break;
        case 5.0:
            //nickel check
            if(insertedCoin.size == 0.835){
                addCoinToTotal(coin: insertedCoin, type: .nickel)
            }
            else{
                rejectCoin(coin: insertedCoin)
            }
            break;
        default:
            //any other coin is automatically returned
            rejectCoin(coin: insertedCoin)
            break;
        }
    }
    
    //update main vending message based on coins inserted
    func updateTotal(coinValue: Double){
        if(coinValue > 0){
            moneyInserted += coinValue
            vendingMessageLabel.text = "Inserted: " + currencyFormatter.string(from: NSNumber(value: moneyInserted))!
        }
        else{
            vendingMessageLabel.text = defaultMessage
        }
    }
    
    //serves as the coin repository for returned coins
    func returnCoins(){
        returnedCoins.append(contentsOf: insertedCoins)
        insertedCoins.removeAll()
        vendingMessageLabel.text = defaultMessage
        moneyInserted = 0.0
        updateReturnedLabel()
    }
    
    //removes coins from the returned coins repository and back to the customer
    func collectChange(){
        customerCoins.append(contentsOf: returnedCoins)
        returnedCoins.removeAll()
        updateReturnedLabel()
        updateCoinCount()
    }
    
    //adds validated coin values to the machine for purchases
    func addCoinToTotal(coin: Coin, type: CoinType){
        insertedCoins.append(coin)
        switch(type){
        case .quarter:
            updateTotal(coinValue: 0.25)
            break
        case .dime:
            updateTotal(coinValue: 0.10)
            break
        case .nickel:
            updateTotal(coinValue: 0.05)
            break
        }
    }
    
    //coins like pennies go directly to the return slot after being weighed and measured
    func rejectCoin(coin: Coin){
        returnedCoins.append(coin)
        updateReturnedLabel()
    }
    
    //updates the returned coins label so we can show how many coins are available to be picked up
    func updateReturnedLabel(){
        returnCoinsButton.setTitle("Return Coins (" + String(returnedCoins.count) + ")", for: .normal)
    }
}


