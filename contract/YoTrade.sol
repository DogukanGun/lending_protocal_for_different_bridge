pragma solidity 0.8.18;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract YoTreade{

    struct Deposit{
        uint256 depositAmount;
        uint256 targetAmount;
        uint256 timeStamp;
        uint256 totalDay;
        bool isActive;
    }

    uint256 public dayCount = 0;
    uint256 floatMultiply;

    //1 represents balance on ether, 2 represents balance on bitcoin
    uint256 balanceWay = 1;

    AggregatorV3Interface internal priceFeedForEth;
    AggregatorV3Interface internal priceFeedForBTC;
    event RatioCalculated(uint256 ratio,uint256 etcValue, uint256 btcValue);

    mapping(uint256 => uint256) dayExchanceRates;
    mapping(address => Deposit) public  deposits;

    // pool fee to 0.2%.
    uint24 public constant poolFee = 2000;

    address developerWalletAddress = address(0xC172989e281a7086Cf2752Daf18c469DBd9aC937);

    constructor() {
        priceFeedForEth = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        priceFeedForBTC = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
        floatMultiply = 2;
    }

    function deposit(uint256 targetAmount, uint256 totalDay) external payable returns(bool sent, bytes memory data){
        require(msg.value > 0, "Deposit amount cannot be negative");
        address payable contractAddress = payable(address(this));
        (bool sent, bytes memory data) = contractAddress.call{value: msg.value}("");
        if(deposits[msg.sender].depositAmount != 0){
            deposits[msg.sender].depositAmount += msg.value;
        }else{
            Deposit memory newDeposit;
            newDeposit.targetAmount = targetAmount;
            newDeposit.depositAmount = msg.value;
            newDeposit.timeStamp = block.timestamp;
            newDeposit.totalDay = totalDay;
            newDeposit.isActive = true;
            deposits[msg.sender] = newDeposit;
        }
        return (sent,data);
    }

    function withdraw(address user,uint256 withdrawAmount) external payable returns(bool sent, bytes memory data){
        require(deposits[msg.sender].isActive, "You draw all your money before");
        require(deposits[msg.sender].depositAmount >= withdrawAmount, "You can withdraw bigger amount than deposit");
        require(deposits[msg.sender].targetAmount <= deposits[msg.sender].depositAmount 
        && calculateDaysSinceCreation(deposits[msg.sender].timeStamp) >= deposits[msg.sender].totalDay
        ,"Please wait more to take your money");
        address payable contractAddressPayable = payable(address(user));
        (bool sent, bytes memory data) = contractAddressPayable.call{value: withdrawAmount}("");
        require(sent, "Transfer failed");
        deposits[msg.sender].depositAmount -= withdrawAmount;
        if(deposits[msg.sender].depositAmount == 0){
            deposits[msg.sender].isActive = false;
        }
        return (sent,data);
    }

    function saveContract() external payable {
        require(msg.sender == developerWalletAddress," You must be developer");
        address payable contractAddress = payable(developerWalletAddress);
        contractAddress.transfer(address(this).balance); 
    }

    function calculateDaysSinceCreation(uint256 creationTimestamp) public view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 elapsedTime = currentTime - creationTimestamp;
        uint256 elapsedDays = elapsedTime / 86400; // Number of seconds in a day: 86400
        return elapsedDays;
    }



    //takas yap


    function exchange() public{
        uint256 ethValue = this.getEthValue();
        uint256 btcValue = this.getBtcValue();
        uint256 ratio = ((ethValue * 1000/btcValue) );
        if(dayCount != 0){
            if(balanceWay == 1){
                if((ratio/1000) > (dayExchanceRates[dayCount] * floatMultiply / 100)){
                    // takas yap eth -> btc  
                
                }
            }else if(balanceWay == 2){
                if((ratio/1000) < (dayExchanceRates[dayCount] * floatMultiply / 100)){
                    // takas yap btc -> eth 
                }
            }
        }
        emit RatioCalculated(ratio,ethValue,btcValue);
        dayExchanceRates[dayCount] = ratio;
        dayCount = dayCount + 1;
    }

    function getExchanceRateForDay(uint256 day)  external view returns(uint256){
        return dayExchanceRates[day];
    }

    function getEthValue() external view returns(uint256) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedForEth.latestRoundData();
        return uint256(price);
    }

    function getBtcValue() external view returns(uint256) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedForBTC.latestRoundData();
        return uint256(price);
    }
}