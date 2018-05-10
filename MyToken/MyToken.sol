pragma solidity ^0.4.0;

contract MyToken {
    /* This creates an array with all balances */
    // 保存每个账户（地址）的额度
    mapping(address => uint256) public balanceOf;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    // 创建账户时初始化token的发行量
    function MyToken(
        uint256 initialSupply
    ) public {
        //将初始化的token记录在合约创建者的账户
        balanceOf[msg.sender] = initialSupply;
        // Give the creator all initial tokens
    }

    /* Send coins */
    // 转账
    function transfer(address _to, uint256 _value) public {
        // 检查是否账户额度足够转账
        require(balanceOf[msg.sender] >= _value);
        // Check if the sender has enough
        // 确保收款账户余额加转账金额不发生溢出
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Check for overflows
        // 发送者减去转账金额
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        // 接收者增加转账金额
        balanceOf[_to] += _value;
        // Add the same to the recipient
    }
}