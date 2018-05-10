pragma solidity ^0.4.0;
// 参考 http://wiki.jikexueyuan.com/project/solidity-zh/introduction-smart-contracts.html

contract SimpleStorage {
//    256bits无符号整数
    uint storedData;
//    设置变量的值
    function set(uint x) {
        storedData = x;
    }
//    查询变量的值
    function get() constant returns (uint retVal) {
        return storedData;
    }

}
