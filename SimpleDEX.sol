// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;


/*
 * @title SimpleDEX
 * @author Bugallo Sergio
 * @dev Only fFor educational purposes, implements a simple DEX.
 * @notice Trabajo Final Buenos Aires EDP Modulo3 (ETHKIPU)   
 * Considerations about this contract: Implement a exchange contract (mandatorily named SimpleDEX) that:
 * 1- Maintains a liquidity pool for TokenA and TokenB.
 * 2- Uses the constant product formula (x+dx)*(y-dy) = x*y to calculate exchange prices.
 * 3- Allows adding and removing liquidity (onlyOwner).
 * 4- Allows exchanging TokenA for TokenB and vice versa.
 * 5- The contract must mandatorily include the following functions without modifying the interface:
   - constructor(address _tokenA, address _tokenB) --> done
   - addLiquidity(uint256 amountA, uint256 amountB) -->  done
   - swapAforB(uint256 amountAIn)  -->  done
   - swapBforA(uint256 amountBIn)  -->  done
   - removeLiquidity(uint256 amountA, uint256 amountB) -->  done
   - getPrice(address _token)  -->  done
 * 6- Include the events deemed appropriate:
   - LiquidityAdded:Añadir liquidez.  --> done
   - TokensSwapped:Intercambiar tokens. -->  done
   - LiquidityRemoved:Retirar liquidez.  --> done
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract SimpleDEX is Ownable {
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event TokensSwapped(address indexed swapper, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

    constructor(address _tokenA, address _tokenB)
        Ownable(msg.sender)
    {
        require(_tokenA != address(0) && _tokenB != address(0), "Invalid token addresses");
        require(_tokenA != _tokenB, "Tokens must be different");
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB); 
    }

    /**
     * @dev Adds liquidity to the pool. The sender must approve the contract to spend the tokens beforehand.
     * @param amountA Amount of TokenA to add.
     * @param amountB Amount of TokenB to add.
     */
    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA > 0 && amountB > 0, "Amounts must be greater than zero");
        require(tokenA.allowance(msg.sender, address(this)) >= amountA, "TokenA allowance too low");
        require(tokenB.allowance(msg.sender, address(this)) >= amountB, "TokenB allowance too low");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        reserveA += amountA;
        reserveB += amountB;

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /**
     * @dev Removes liquidity from the pool.
     * @param amountA Amount of TokenA to remove.
     * @param amountB Amount of TokenB to remove.
     */
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA <= reserveA && amountB <= reserveB, "Insufficient liquidity");

        reserveA -= amountA;
        reserveB -= amountB;

        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /**
     * @dev Swaps TokenA for TokenB.
     * @param amountAIn Amount of TokenA to swap.
     */
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Amount must be greater than zero");
        require(tokenA.allowance(msg.sender, address(this)) >= amountAIn, "TokenA allowance too low");

        uint256 amountBOut = getAmountOut(amountAIn, reserveA, reserveB);
        
        tokenA.transferFrom(msg.sender, address(this), amountAIn);
        tokenB.transfer(msg.sender, amountBOut);

        reserveA += amountAIn;
        reserveB -= amountBOut;

        emit TokensSwapped(msg.sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /**
     * @dev Swaps TokenB for TokenA.
     * @param amountBIn Amount of TokenB to swap.
     */
    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Amount must be greater than zero");
        require(tokenB.allowance(msg.sender, address(this)) >= amountBIn, "TokenB allowance too low");

        uint256 amountAOut = getAmountOut(amountBIn, reserveB, reserveA);

        tokenB.transferFrom(msg.sender, address(this), amountBIn);
        tokenA.transfer(msg.sender, amountAOut);

        reserveB += amountBIn;
        reserveA -= amountAOut;

        emit TokensSwapped(msg.sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

    /**
     * @dev Calculates the output amount using the constant product formula.
     * @param amountIn Input token amount.
     * @param reserveIn Input token reserve.
     * @param reserveOut Output token reserve.
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");
 
        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        return numerator / denominator;
    }

    /**
     * @dev Returns the price of a token based on the reserves.
     * @param _token The address of the token to get the price for.
     */
    function getPrice(address _token) external view returns (uint256) {
        if (_token == address(tokenA)) {
            return (reserveB * 1e18) / reserveA; // Price of 1 TokenA in terms of TokenB
        } else if (_token == address(tokenB)) {
            return (reserveA * 1e18) / reserveB; // Price of 1 TokenB in terms of TokenA
        } else {
            revert("Token not supported");
        }
    }

}