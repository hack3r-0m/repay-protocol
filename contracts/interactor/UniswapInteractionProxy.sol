// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "../utils/ERC2771Context.sol";

import "../interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

/* solhint-disable no-empty-blocks */
/* solhint-disable max-line-length */
/* solhint-disable var-name-mixedcase */
/* solhint-disable func-param-name-mixedcase */

contract UniswapInteractionProxy is ERC2771Context {

    address public UNISWAP_V2_ROUTER;
    address public UNISWAP_V2_FACTORY;

    address payable public owner;
    address public proxy;

    constructor(address _trustedForwarder, address UNISWAP_V2_ROUTER_, address UNISWAP_V2_FACTORY_)
    ERC2771Context(_trustedForwarder) {

        owner = payable(_msgSender());
        proxy = msg.sender;

        UNISWAP_V2_ROUTER = UNISWAP_V2_ROUTER_;
        UNISWAP_V2_FACTORY = UNISWAP_V2_FACTORY_;
    }
    
    IUniswapV2Router01 internal _router = IUniswapV2Router01(UNISWAP_V2_ROUTER);
    IUniswapV2Factory internal _factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    function versionRecipient() external pure returns (string memory) {
        return "2.2.2";
    }

    /**
     * @notice making functions callable via owner or proxy incase proxy does not use GSN
     */
    
    modifier onlyOwnerOrProxy {
        require(_msgSender() == owner || _msgSender() == proxy, "ONLY_OWNER");
        _;
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external onlyOwnerOrProxy {

        IERC20 _tokenA = IERC20(tokenA);
        IERC20 _tokenB = IERC20(tokenB);

        uint256 _allowanceA = _tokenA.allowance(owner, address(this));
        uint256 _allowanceB = _tokenB.allowance(owner, address(this));

        require(_allowanceA > 0 && _allowanceB > 0, "BOTH_TOKENS_NOT_APPROVED_TO_PROXY");

        _tokenA.transferFrom(owner, address(this), _allowanceA) &&
        _tokenA.approve(UNISWAP_V2_ROUTER, _tokenA.balanceOf(address(this)));

        _tokenB.transferFrom(owner, address(this), _allowanceB) &&
        _tokenB.approve(UNISWAP_V2_ROUTER, _tokenB.balanceOf(address(this)));

        (,, uint liquidity) = _router.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);

        address lpToken = _factory.getPair(tokenA, tokenB);
        IERC20(lpToken).transfer(owner, liquidity);
    }

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable {

        IERC20 _token = IERC20(token);

        uint256 _allowance = _token.allowance(owner, address(this));

        require(_allowance > 0, "TOKENS_NOT_APPROVED_TO_PROXY");

        _token.transferFrom(owner, address(this), _allowance) &&
        _token.approve(UNISWAP_V2_ROUTER, _token.balanceOf(address(this)));

        (,, uint liquidity) = _router.addLiquidityETH{value: msg.value}(token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline);

        IERC20 lpToken = IERC20(_factory.getPair(token, _router.WETH()));
        lpToken.transfer(owner, liquidity);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external onlyOwnerOrProxy returns (uint amountA, uint amountB) {
        return _router.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external onlyOwnerOrProxy returns (uint amountToken, uint amountETH) {
        return _router.removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external onlyOwnerOrProxy returns (uint[] memory) {

        /* The first element of path is the input token, 
         * the last is the output token
         * any intermediate elements represent intermediate tokens to trade through
         */

        address inputToken = path[0];
        address outputToken = path[path.length -1];

        IERC20 _inputToken = IERC20(inputToken);
        IERC20 _outputToken = IERC20(outputToken);

        uint256 _allowance = _inputToken.allowance(owner, address(this));

        if(_allowance > 0)  _inputToken.transferFrom(owner, address(this), amountInMax) &&
        _inputToken.approve(UNISWAP_V2_ROUTER, _inputToken.balanceOf(address(this)));
        
        uint[] memory amounts = _router.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);

        _outputToken.transfer(owner, amounts[amounts.length-1]);

        return amounts;
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable onlyOwnerOrProxy
        returns (uint[] memory) {

        address outputToken = path[path.length -1];
        IERC20 _outputToken = IERC20(outputToken);
        
        uint[] memory amounts = _router.swapExactETHForTokens{value: msg.value}(amountOutMin, path, to, deadline);

        _outputToken.transfer(owner, amounts[amounts.length-1]);

        return amounts;      
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external onlyOwnerOrProxy
        returns (uint[] memory) {

        address inputToken = path[0];

        IERC20 _inputToken = IERC20(inputToken);

        uint256 _allowance = _inputToken.allowance(owner, address(this));

        if(_allowance > 0)  _inputToken.transferFrom(owner, address(this), amountInMax) &&
        _inputToken.approve(UNISWAP_V2_ROUTER, _inputToken.balanceOf(address(this)));
        
        uint[] memory amounts = _router.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);

        owner.transfer(amounts[amounts.length-1]);

        return amounts;

    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external onlyOwnerOrProxy
        returns (uint[] memory) {

        address inputToken = path[0];

        IERC20 _inputToken = IERC20(inputToken);

        uint256 _allowance = _inputToken.allowance(owner, address(this));

        if(_allowance > 0)  _inputToken.transferFrom(owner, address(this), amountIn) &&
        _inputToken.approve(UNISWAP_V2_ROUTER, _inputToken.balanceOf(address(this)));
        
        uint[] memory amounts = _router.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);

        owner.transfer(amounts[amounts.length-1]);

        return amounts;

    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable onlyOwnerOrProxy
        returns (uint[] memory) {

        address outputToken = path[path.length -1];
        IERC20 _outputToken = IERC20(outputToken);
        
        uint[] memory amounts = _router.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        _outputToken.transfer(owner, amounts[amounts.length-1]);

        return amounts;  
    }

}
