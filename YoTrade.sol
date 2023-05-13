pragma solidity 0.8.18;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract YoTreade{

    uint256 public dayCount = 0;
    uint256 floatMultiply;

    //1 represents balance on ether, 2 represents balance on bitcoin
    uint256 balanceWay = 1;

    AggregatorV3Interface internal priceFeedForEth;
    AggregatorV3Interface internal priceFeedForBTC;
    event RatioCalculated(uint256 ratio,uint256 etcValue, uint256 btcValue);

    mapping(uint256 => uint256) dayExchanceRates;

    // pool fee to 0.2%.
    uint24 public constant poolFee = 2000;

    constructor() {
        priceFeedForEth = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        priceFeedForBTC = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
        floatMultiply = 2;
    }

    //deposit al
    //withdraw al
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