// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

contract Split is OwnerIsCreator {

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);
    error NothingToWithdraw();
    error FailedToWithdrawEth(address owner, address target, uint256 value);
    error DestinationChainNotWhitelisted(uint64 destinationChainSelector);

    event TokensTransferred(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        address token, // The token address that was transferred.
        uint256 tokenAmount, // The token amount that was transferred.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.
    );
    
    mapping(uint64 => bool) public whitelistedChains;

    IRouterClient router;
    LinkTokenInterface linkToken;

    constructor(address _router, address _link) {
        router = IRouterClient(_router);
        linkToken = LinkTokenInterface(_link);
    }

    modifier onlyWhitelistedChain(uint64 _destinationChainSelector) {
        if (!whitelistedChains[_destinationChainSelector])
            revert DestinationChainNotWhitelisted(_destinationChainSelector);
        _;
    }

    function whitelistChain(uint64 _destinationChainSelector ) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = true;
    }

    function denylistChain(uint64 _destinationChainSelector) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = false;
    }

    /* Pay with Link token when transferring token */
    function transferTokensPayLINK(uint64 _destinationChainSelector, address _receiver, address _token, uint256 _amount) 
        external onlyOwner onlyWhitelistedChain(_destinationChainSelector) returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(_receiver, _token, _amount, address(linkToken));
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage); // Get the fee required to send the message

        if (fees > linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(linkToken.balanceOf(address(this)), fees);

        linkToken.approve(address(router), fees); // approve the Router to transfer LINK tokens on contract's behalf. It will spend the fees in LINK
        IERC20(_token).approve(address(router), _amount); // approve the Router to spend tokens on contract's behalf. It will spend the amount of the given token
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage); // Send the message through the router and store the returned message ID
        emit TokensTransferred(messageId, _destinationChainSelector, _receiver, _token, _amount, address(linkToken), fees);

        return messageId;
    }
    
    /* Pay with native token when transferring token */
    function transferTokensPayNative(uint64 _destinationChainSelector, address _receiver, address _token, uint256 _amount) 
    public onlyOwner onlyWhitelistedChain(_destinationChainSelector) returns (bytes32 messageId)
    {
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(_receiver, _token, _amount, address(0));
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > address(this).balance)
            revert NotEnoughBalance(address(this).balance, fees);

        IERC20(_token).approve(address(router), _amount); // approve the Router to spend tokens on contract's behalf. It will spend the amount of the given token
        messageId = router.ccipSend{value: fees}(_destinationChainSelector, evm2AnyMessage); // Send the message through the router and store the returned message ID
        emit TokensTransferred(messageId, _destinationChainSelector, _receiver, _token, _amount, address(0), fees);

        return messageId;
    }

    /* 
        Starts: my implementation of split payment
    */
    struct Transaction {
        address senderAddress;
        uint64 chain;
        uint256 amount;
    }

    Transaction[] public transactions;
    address tok = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05; //CCIP BnM

    function addTransactions(Transaction[] memory _groupedTransactions) public onlyOwner {
        for (uint256 i = 0; i < _groupedTransactions.length; i++) {
            transactions.push(_groupedTransactions[i]);
        }
    }

    function getTransaction(uint256 index) public view returns (address, uint64, uint256) {
        require(index < transactions.length, "Index out of bounds");
        Transaction storage transaction = transactions[index];
        return (transaction.senderAddress, transaction.chain, transaction.amount);
    }

    function split() public onlyOwner {
        for(uint256 i = 0; i < transactions.length; i++) {
            transferTokensPayNative(transactions[i].chain, transactions[i].senderAddress, tok, transactions[i].amount) ;
        }
        
    }

    function transactionData() public onlyOwner {
        delete transactions;
    }
    
    // add functionality to add money to contract when balance falls via chainlink automate


    /* 
        Ends: my implementation of split payment
    */

    function _buildCCIPMessage(
        address _receiver, // The address of the receiver.
        address _token, // The token to be transferred.
        uint256 _amount, // The address of the token used for fees. Set address(0) for native gas.
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Set the token amounts
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver), // ABI-encoded receiver address
            data: "", // No data
            tokenAmounts: tokenAmounts, // The amount and type of token being transferred
            extraArgs: Client._argsToBytes(
                // Additional arguments, setting gas limit to 0 as we are not sending any data and non-strict sequencing mode
                Client.EVMExtraArgsV1({gasLimit: 0, strict: false})
            ),
            // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
            feeToken: _feeTokenAddress
        });
        return evm2AnyMessage; // Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    }

    receive() external payable {}


    function withdraw(address _beneficiary) public onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) revert NothingToWithdraw();
        (bool sent, ) = _beneficiary.call{value: amount}("");
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    function withdrawToken(address _beneficiary, address _token) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        IERC20(_token).transfer(_beneficiary, amount);
    }
}
