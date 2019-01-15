pragma solidity ^0.4.24;


import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Voting {
  using SafeMath for uint;

  // Array of Poll structs
  Poll[] public polls;
  mapping(address => uint[]) public participatedPolls;
  // Number of polls that have been created
  uint public pollCount;
  // Mintable VotingToken
  address public enigma;

  // Voter struct which holds, most notably, the weight and encrypted vote
  struct Voter {
    bool hasVoted;
    bytes vote;
  }

  // Poll struct which holds poll information, including mapping of voterInfo 
  struct Poll {
    address creator;
    PollStatus status;
    uint yeaVotes;
    uint nayVotes;
    string description;
    address[] voters;
    uint expirationTime;
    mapping(address => Voter) voterInfo;
  }

  // Event emitted upon casting a vote
  event VoteCasted(address voter, uint pollID, bytes vote);
  // Event emitted upon creating a poll
  event PollCreated(address creator, uint pollID, string description, uint votingLength);
  // Event emitted upon callback completion; watched from front end
  event PollStatusUpdate(bool status);

  // Enum for current state of a poll
  enum PollStatus { IN_PROGRESS, PASSED, REJECTED }

  // Modifier to ensure the poll id is a valid one
  modifier validPoll(uint _pollID) {
    require(_pollID >= 0 && _pollID < pollCount, "Not a valid poll Id.");
    _;
  }

  // Modifier to ensure only enigma contract can call function
  modifier onlyEnigma() {
    require(msg.sender == enigma);
    _;
  }

  // Constructor called when new contract is deployed
  constructor(address _enigma) public {
    require(_enigma != 0 && address(enigma) == 0);
    enigma = _enigma;
  }

  // ** POLL OPERATIONS ** //
  // Create new poll with description, vote length (s), and number of choices
  function createPoll(string _description, uint _voteLength) 
    external 
    returns (uint)
  {
    require(_voteLength > 0, "The voting period cannot be 0.");
    Poll memory curPoll;
    curPoll.creator = msg.sender;
    curPoll.status = PollStatus.IN_PROGRESS;
    curPoll.description = _description;
    curPoll.expirationTime = now + _voteLength * 1 seconds;
    polls.push(curPoll);
    pollCount++; 
    emit PollCreated(msg.sender, pollCount, _description, 
      _voteLength);
    return pollCount; 
  }

  // Get the status of a poll
  function getPollStatus(uint _pollID) 
    public 
    view 
    validPoll(_pollID) 
    returns (PollStatus) 
  {
    return polls[_pollID].status;
  }

  // Get the expiration date of a poll
  function getPollExpirationTime(uint _pollID) 
    public 
    view
    validPoll(_pollID) 
    returns (uint) 
  {
    return polls[_pollID].expirationTime;
  }

  // Get list of polls user has voted in
  function getPollHistory(address _voter) public view returns(uint[]) {
    return participatedPolls[_voter];
  }

  // Get encrypted vote for a particular poll and user
  function getPollInfoForVoter(uint _pollID, address _voter) 
    public 
    view 
    validPoll(_pollID) 
    returns (bytes) 
  {
    require(userHasVoted(_pollID, _voter));
    Poll storage curPoll = polls[_pollID];
    bytes vote = curPoll.voterInfo[_voter].vote;
    return (vote);
  }

  // Get all the voters for a particular poll
  function getVotersForPoll(uint _pollID) 
    public 
    view 
    validPoll(_pollID) 
    returns (address[]) 
  {
    return polls[_pollID].voters;
  }

  // ** VOTE OPERATIONS ** //
  // Cast a vote for a poll with encrypted vote argument
  function castVote(uint _pollID, bytes _encryptedVote) 
    external 
    validPoll(_pollID) 
  {
    require(getPollStatus(_pollID) == PollStatus.IN_PROGRESS, 
      "Poll has expired.");
    require(!userHasVoted(_pollID, msg.sender), "User has already voted.");
    require(getPollExpirationTime(_pollID) > now);
    participatedPolls[msg.sender].push(_pollID);
    Poll storage curPoll = polls[_pollID];
    curPoll.voterInfo[msg.sender] = Voter({
        hasVoted: true,
        vote: _encryptedVote
    });
    curPoll.voters.push(msg.sender);
    emit VoteCasted(msg.sender, _pollID, _encryptedVote);
  }

  // Check if user has voted in a specific poll
  function userHasVoted(uint _pollID, address _user) 
    public 
    view 
    validPoll(_pollID) 
    returns (bool) 
  {
    return (polls[_pollID].voterInfo[_user].hasVoted);
  }

  /*
  CALLABLE FUNCTION run in SGX to decipher encrypted votes and weights to 
  tally results of poll
  */
  function countVotes(uint _pollID, uint[] _votes) 
    public 
    pure 
    returns (uint, uint, uint) 
  {
    uint yeaVotes;
    uint nayVotes;
    for (uint i = 0; i < _votes.length; i++) {
      if (_votes[i] == 0) nayVotes += 1;
      else if (_votes[i] == 1) yeaVotes += 1;
    }
    return (_pollID, yeaVotes, nayVotes);
  }

  /*
  CALLBACK FUNCTION to change contract state with poll results
  */
  function updatePollStatus(uint _pollID, uint _yeaVotes, uint _nayVotes) 
    public 
    validPoll(_pollID) 
    onlyEnigma() 
  {
    Poll storage curPoll = polls[_pollID];
    curPoll.yeaVotes = _yeaVotes;
    curPoll.nayVotes = _nayVotes;
    bool pollStatus = (curPoll.yeaVotes) >= (curPoll.nayVotes);
    if (pollStatus) {
      curPoll.status = PollStatus.PASSED;
    }
    else {
      curPoll.status = PollStatus.REJECTED;
    }
    emit PollStatusUpdate(pollStatus);
  }
}