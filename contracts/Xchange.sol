// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// Uniswap Router and Factory contracts
interface IUniswapV2Router {
  function getAmountsOut(
    uint amountIn,
    address[] calldata path
  ) external view returns (uint[] memory amounts);

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external returns (uint[] memory amounts);

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  ) external;
}

interface IUniswapV2Factory {
  function createPair(
    address tokenA,
    address tokenB
  ) external returns (address pair);
}

contract Xchange is ReentrancyGuard {
  address private constant ETH_ADDRESS =
    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address private owner;
  address[] private feeAccounts;
  uint256 private feePercentage;
  uint256 private discountFeePercentage;
  IUniswapV2Router private uniswapRouter;
  IUniswapV2Factory private uniswapFactory;

  modifier onlyOwner() {
    require(msg.sender == owner, "Only contract owner can call this function.");
    _;
  }

  constructor(
    address[] memory _feeAccounts,
    uint256 _feePercentage,
    uint256 _discountFeePercentage
  ) {
    require(_feeAccounts.length > 0, "At least one fee account is required");
    require(_feePercentage <= 100, "Invalid fee percentage");
    require(_discountFeePercentage <= 100, "Invalid discount fee percentage");

    owner = msg.sender;
    feeAccounts = _feeAccounts;
    feePercentage = _feePercentage;
    discountFeePercentage = _discountFeePercentage;
    // Initialize the Uniswap Router and Factory contracts
    uniswapRouter = IUniswapV2Router(
      0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    uniswapFactory = IUniswapV2Factory(
      0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f
    );
  }

  /* function swapTokens(address _tokenIn, address _tokenOut, uint256 _amountIn) external payable {
        if (_tokenIn == ETH_ADDRESS) {
            require(msg.value == _amountIn, "Incorrect ETH amount");
        } else {
            IERC20 tokenIn = IERC20(_tokenIn);
            require(tokenIn.balanceOf(msg.sender) >= _amountIn, "Insufficient balance");
            require(tokenIn.allowance(msg.sender, address(this)) >= _amountIn, "Insufficient allowance");
            tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        }

        uint256 fee = calculateFee(_amountIn);
        uint256 amountAfterFee = _amountIn - fee;


         // Transfer tokens from sender to the contract
        _tokenIn.transferFrom(msg.sender, address(this), _amountIn);

       // Swap tokens using Uniswap
       address[] memory path = getPath(_tokenIn, _tokenOut);
      if (_tokenIn == ETH_ADDRESS) {
        uniswapRouter.swapExactTokensForTokens(_amountIn, amountAfterFee, path, msg.sender, block.timestamp);
      //uniswapRouter.swapExactTokensForTokens{value: msg.value}(_amountIn, amountAfterFee, path, msg.sender, block.timestamp);
     } else {
    IERC20 tokenIn = IERC20(_tokenIn);
    tokenIn.approve(address(uniswapRouter), _amountIn);
    uniswapRouter.swapExactTokensForTokens(_amountIn, amountAfterFee, path, msg.sender, block.timestamp);
    
     // Split fee among fee accounts
     //   splitFee(_tokenIn, fee);


     }
    }*/

  function swapTokens(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn
  ) external {
    IERC20 tokenIn = IERC20(_tokenIn);

    //IERC20 tokenOut = IERC20(_tokenOut);
    require(tokenIn.balanceOf(msg.sender) >= _amountIn, "Insufficient balance");
    require(
      tokenIn.allowance(msg.sender, address(this)) >= _amountIn,
      "Insufficient allowance"
    );

    uint256 fee = calculateFee(_amountIn);
    uint256 amountAfterFee = _amountIn - fee;

    // Transfer tokens from sender to the contract
    tokenIn.transferFrom(msg.sender, address(this), _amountIn);

    // Swap tokens using Uniswap
    address[] memory path = getPath(_tokenIn, _tokenOut);
    tokenIn.approve(address(uniswapRouter), _amountIn);
    uniswapRouter.swapExactTokensForTokens(
      _amountIn,
      amountAfterFee,
      path,
      msg.sender,
      block.timestamp
    );

    // Convert the collected tokens into ETH
    uint256 tokenOutBalance = IERC20(_tokenOut).balanceOf(address(this));
    address[] memory ethPath = getPath(_tokenOut, ETH_ADDRESS);
    IERC20(_tokenOut).approve(address(uniswapRouter), tokenOutBalance);
    uniswapRouter.swapExactTokensForETH(
      tokenOutBalance,
      0,
      ethPath,
      address(this),
      block.timestamp
    );

    // Distribute the converted ETH fees to the fee accounts
    uint256 ethBalance = address(this).balance;
    uint256 feeShare = ethBalance / feeAccounts.length;
    for (uint256 i = 0; i < feeAccounts.length; i++) {
      payable(feeAccounts[i]).transfer(feeShare);
    }
  }

  function getPath(
    address _tokenIn,
    address _tokenOut
  ) private pure returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = _tokenIn;
    path[1] = _tokenOut;
    return path;
  }

  /*function getPath(address _tokenIn, address _tokenOut) private view returns (address[] memory) {
    if (_tokenIn == ETH_ADDRESS || _tokenOut == ETH_ADDRESS) {
        address[] memory path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;
        return path;
    } else {
        address[] memory path = new address[](3);
        path[0] = _tokenIn;
        path[1] = ETH_ADDRESS;
        path[2] = _tokenOut;
        return path;
    }
}*/

  function calculateFee(uint256 _amount) private view returns (uint256) {
    if (isLastFriday()) {
      return (_amount * discountFeePercentage) / 10000; // 0.2% fee
    } else {
      return (_amount * feePercentage) / 10000; // 0.25% fee
    }
  }

  function isLastFriday() private view returns (bool) {
    uint256 today = block.timestamp;
    uint256 lastDayOfMonth = getLastDayOfMonth(today);
    uint256 lastFridayOfMonth = getLastFridayOfMonth(lastDayOfMonth);
    return (today == lastFridayOfMonth);
  }

  function getLastDayOfMonth(
    uint256 _timestamp
  ) private pure returns (uint256) {
    uint256 year = getYear(_timestamp);
    uint256 month = getMonth(_timestamp);
    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }
    uint256 lastDayOfMonth = getDaysInMonth(year, month);
    return getTimestamp(year, month, lastDayOfMonth);
  }

  function getLastFridayOfMonth(
    uint256 _timestamp
  ) private pure returns (uint256) {
    uint256 year = getYear(_timestamp);
    uint256 month = getMonth(_timestamp);
    uint256 lastDayOfMonth = getDaysInMonth(year, month);
    for (uint256 day = lastDayOfMonth; day >= 1; day--) {
      if (getWeekday(getTimestamp(year, month, day)) == 5) {
        // 5 corresponds to Friday
        return getTimestamp(year, month, day);
      }
    }
    revert("Last Friday not found");
  }

  function getDaysInMonth(
    uint256 _year,
    uint256 _month
  ) private pure returns (uint256) {
    if (
      _month == 1 ||
      _month == 3 ||
      _month == 5 ||
      _month == 7 ||
      _month == 8 ||
      _month == 10 ||
      _month == 12
    ) {
      return 31;
    } else if (_month == 4 || _month == 6 || _month == 9 || _month == 11) {
      return 30;
    } else if (isLeapYear(_year)) {
      return 29;
    } else {
      return 28;
    }
  }

  function getYear(uint256 _timestamp) private pure returns (uint256) {
    return uint256(((_timestamp / 86400) + 4) / 1461);
  }

  function getMonth(uint256 _timestamp) private pure returns (uint256) {
    uint256 doy = (_timestamp / 86400) -
      (((_timestamp / 86400) + 4) / 1461) *
      1461 +
      1;
    uint256 month = (doy - 1) / 30 + 1;
    if (month >= 12) {
      return month - 12;
    } else {
      return month;
    }
  }

  function getWeekday(uint256 _timestamp) private pure returns (uint256) {
    return (((_timestamp / 86400) + 3) % 7) + 1;
  }

  function getTimestamp(
    uint256 _year,
    uint256 _month,
    uint256 _day
  ) private pure returns (uint256) {
    // return (uint256((_year - 1) * 365 + (_year - 1) / 4 - (_year - 1) / 100 + (_year - 1) / 400 +
    //    ((_month * 367) - 362) / 12 + ((_month <= 2) ? 0 : (isLeapYear(_year) ? -1 : -2)) + _day - 1) * 86400);
    // }
    // return (uint256((_year - 1) * 365 + (_year - 1) / 4 - (_year - 1) / 100 + (_year - 1) / 400 +
    // ((_month * 367) - 362) / 12 + ((_month <= 2) ? 0 : (uint8(isLeapYear(_year)) ? uint8(-1) : uint8(-2))) + _day - 1) * 86400);
    // }

    return (uint256(
      (_year - 1) *
        365 +
        (_year - 1) /
        4 -
        (_year - 1) /
        100 +
        (_year - 1) /
        400 +
        ((_month * 367) - 362) /
        12 +
        ((_month <= 2) ? 0 : ((isLeapYear(_year) ? 255 : 254))) +
        _day -
        1
    ) * 86400);
  }

  function isLeapYear(uint256 _year) private pure returns (bool) {
    return (_year % 4 == 0 && (_year % 100 != 0 || _year % 400 == 0));
  }

  function splitFees() external payable {
    require(msg.value > 0, "No fees to split");

    uint256 feeAmount = (msg.value * feePercentage) / 100;
    uint256 discountFeeAmount = (msg.value * discountFeePercentage) / 100;
    uint256 remainingFeeAmount = msg.value - feeAmount - discountFeeAmount;

    for (uint256 i = 0; i < feeAccounts.length; i++) {
      if (feeAccounts[i] != address(0)) {
        uint256 feeShare = (feeAmount * (10 ** 18)) / feeAccounts.length;
        (bool success, ) = feeAccounts[i].call{value: feeShare}("");
        require(success, "Fee transfer failed");
      }
    }
    if (discountFeeAmount > 0) {
      (bool success, ) = owner.call{value: discountFeeAmount}("");
      require(success, "Discount fee transfer failed");
    }
    if (remainingFeeAmount > 0) {
      (bool success, ) = owner.call{value: remainingFeeAmount}("");
      require(success, "Remaining fee transfer failed");
    }
  }

  function setFeeAccounts(address[] memory _feeAccounts) external onlyOwner {
    require(_feeAccounts.length > 0, "At least one fee account is required");
    feeAccounts = _feeAccounts;
  }

  function setFeePercentage(uint256 _feePercentage) external onlyOwner {
    require(_feePercentage <= 100, "Invalid fee percentage");
    feePercentage = _feePercentage;
  }

  function setDiscountFeePercentage(
    uint256 _discountFeePercentage
  ) external onlyOwner {
    require(_discountFeePercentage <= 100, "Invalid discount fee percentage");
    discountFeePercentage = _discountFeePercentage;
  }

  /* function withdrawTokens(address _token, uint256 _amount) external onlyOwner {
    IERC20 token = IERC20(_token);
    require(
      token.balanceOf(address(this)) >= _amount,
      "Insufficient contract balance"
    );
    token.transfer(owner, _amount);
  } */
  function withdrawTokens(address _tokenAddress) external onlyOwner {
    require(
      _tokenAddress != address(0) && _tokenAddress != ETH_ADDRESS,
      "Invalid token address"
    );

    IERC20 token = IERC20(_tokenAddress);
    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance > 0, "No tokens to withdraw");

    bool success = token.transfer(owner, tokenBalance);
    require(success, "Token transfer failed");
  }

  function withdrawETH(uint256 _amount) external onlyOwner {
    require(address(this).balance >= _amount, "Insufficient contract balance");
    (bool success, ) = owner.call{value: _amount}("");
    require(success, "ETH transfer failed");
  }
}
