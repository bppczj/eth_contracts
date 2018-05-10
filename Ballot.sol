pragma solidity ^0.4.0;

contract Ballot {
    // 这里声明了复杂类型
    // 将会在被后面的参数使用
    // 代表一个独立的投票人。
    struct Voter {
        uint weight; // 累积的权重
        bool voted; // 如果为真，则表示该投票人已经投票
        uint8 vote; // 投票选择的提案索引号
        address delegate; // 委托的投票代表
    }
    // 这是一个独立提案的类型
    struct Proposal {
        bytes32 name;   // 短名称（32字节）
        uint voteCount; // 累计获得的票数
    }

    address chairperson;
    //这里声明一个状态变量，保存每个独立地址的`Voter` 结构
    mapping(address => Voter) voters;
    //一个存储`Proposal`结构的动态数组
    Proposal[] proposals;

    /// Create a new ballot with $(_numProposals) different proposals.
    // 创建一个新的投票用于选出一个提案名`proposalNames`.
    function Ballot(bytes32[] proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        //对提供的每一个提案名称，创建一个新的提案
        //对象添加到数组末尾
        for (uint i = 0; i < proposalNames.length; i++)
            //`Proposal({...})` 创建了一个临时的提案对象，
            //`proposal.push(...)`添加到了提案数组`proposals`末尾。
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
    }

    /// Give $(toVoter) the right to vote on this ballot.
    //给投票人`voter`参加投票的投票权，
    /// May only be called by $(chairperson).
    //只能由投票主持人`chairperson`调用
    function giveRightToVote(address toVoter) public {
        if (msg.sender != chairperson || voters[toVoter].voted) return;
        voters[toVoter].weight = 1;
    }

    /// Delegate your vote to the voter $(to).
    // 委托你的投票权到一个投票代表 `to`
    function delegate(address to) public {
        //指定引用
        Voter storage sender = voters[msg.sender]; // assigns reference
        if (sender.voted) return;
        //当投票代表`to`也委托给别人时，寻找到最终的投票代表
        while (voters[to].delegate != address(0) && voters[to].delegate != msg.sender)
            to = voters[to].delegate;
        // 当最终投票代表等于调用者，是不被允许的。
        if (to == msg.sender) return;
         //因为`sender`是一个引用，
         //这里实际修改了`voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegateTo = voters[to];

        if (delegateTo.voted)
            //如果委托的投票代表已经投票了，直接修改票数
            proposals[delegateTo.vote].voteCount += sender.weight;
        else
            //如果投票代表还没有投票，则修改其投票权重。
            delegateTo.weight += sender.weight;
    }

    ///投出你的选票（包括委托给你的选票）
    ///给 `proposals[proposal].name`
    /// Give a single vote to proposal $(toProposal).
    function vote(uint8 toProposal) public {
        Voter storage sender = voters[msg.sender];
        if (sender.voted || toProposal >= proposals.length) return;
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    ///@dev 根据当前所有的投票计算出当前的胜出提案
    function winningProposal() public constant returns (uint _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++)
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
                //_winningProposalName = proposals[prop].name;
            }
    }
}
//usage
//create: ["a","b","c"]
//giveRightToVote: "0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
//vote: 2
//winningProposal: 2
