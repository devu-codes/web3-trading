// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol"; 

contract Exchange {
  address public feeAccount;
  uint256 public feePercent;
  mapping(address => mapping(address => uint256)) public tokens; // token => (user => amount)
  mapping(uint256 => _Order) public orders; // id => Order
  uint256 public ordersCount;
  mapping(uint256 => bool) public orderCancelled; // id => cancelled

  event Deposit(
    address indexed token,
    address indexed user,
    uint256 amount,
    uint256 balance
  );

  event Withdraw(
    address indexed token,
    address indexed user,
    uint256 amount,
    uint256 balance
  );

  event Order(
    uint256 id,
    address user,
    address tokenGet,
    uint256 amountGet,
    address tokenGive,
    uint256 amountGive,
    uint256 timestamp
  );

  event Cancel(
    uint256 id,
    address user,
    address tokenGet,
    uint256 amountGet,
    address tokenGive,
    uint256 amountGive,
    uint256 timestamp
  );

  struct _Order {
    uint256 id; // Unique order id
    address user; // user who made the order
    address tokenGet; // Address of token they want to receive
    uint256 amountGet; // Amount of token they want to receive
    address tokenGive; // Address of token they want to give
    uint256 amountGive; // Amount of token they want to give
    uint256 timestamp; // Time when order was created
  }

  constructor(address _feeAccount, uint256 _feePercent) {
    feeAccount = _feeAccount;
    feePercent = _feePercent; 
  }

  function depositToken(address _token, uint256 _amount) public {
    // Transfer token to exchange
    require(Token(_token).transferFrom(msg.sender, address(this), _amount));
    // Update balance
    tokens[_token][msg.sender] += _amount;
    // Emit deposit event
    emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
  }

  function withdrawToken(address _token, uint256 _amount) public {
    // Check balance
    require(tokens[_token][msg.sender] >= _amount);
    
    Token(_token).transfer(msg.sender, _amount);
    // Transfer token to user
    tokens[_token][msg.sender] -= _amount;
    
    // Emit withdraw event
    emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
  }

  function balanceOf(address _token, address _user)
    public
    view
    returns (uint256)
  {
    return tokens[_token][_user];
  }

  // -------------------------------
  // Make & Cancel Orders

  // Token Give (the token they want to spend)
  // Token Get (the token they want to receive)
  function makeOrder(
    address _tokenGive,
    uint256 _amountGive,
    address _tokenGet,
    uint256 _amountGet
  ) public {
    // Fee account
    // Fee percent
    // Make order
    require(balanceOf(_tokenGive, msg.sender) >= _amountGive);

    ordersCount++;  
    // Create order
    orders[ordersCount] = _Order(
      {
        id: 1,
        user: msg.sender,
        tokenGet: _tokenGet,
        amountGet: _amountGet,
        tokenGive: _tokenGive,
        amountGive: _amountGive,
        timestamp: block.timestamp
      }
    );

    // Emit event
    emit Order(
      ordersCount,
      msg.sender,
      _tokenGet,
      _amountGet,
      _tokenGive,
      _amountGive,
      block.timestamp
    );

  }

  function cancelOrder(uint256 _id) public {
    _Order storage _order = orders[_id];
    
    require(address(_order.user) == msg.sender);
    require(_order.id == _id, "Order does not exist");

    orderCancelled[_id] = true;
    
    emit Cancel(
      _id,
      msg.sender,
      _order.tokenGet,
      _order.amountGet,
      _order.tokenGive,
      _order.amountGive,
      block.timestamp
    );
  }
}