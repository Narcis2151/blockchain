// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract GymMachineManager {
    // Events
    event GymMachineAdded(string name);
    event MachineStateUpdated(string machine, MachineState state);

    // Enums and States
    enum MachineState {
        Inactive,
        Active
    }

    // Structs
    struct GymMachine {
        string name;
        uint voteCount;
        MachineState state;
    }

    // State variables
    address public manager;
    mapping(string => GymMachine) public machines;
    string[] public machineNames;

    // Modifiers
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Unauthorized: Only manager can perform this action."
        );
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function addMachine(string calldata name) public onlyManager {
        require(machines[name].voteCount == 0, "Machine already exists.");
        machines[name] = GymMachine({
            name: name,
            voteCount: 0,
            state: MachineState.Active
        });
        machineNames.push(name);
        emit GymMachineAdded(name);
    }

    function updateMachineState(
        string calldata machineName,
        MachineState state
    ) public onlyManager {
        require(
            machines[machineName].state != state,
            "Machine is already in the requested state."
        );
        machines[machineName].state = state;
        emit MachineStateUpdated(machineName, state);
    }

    function getAllMachines()
        public
        view
        returns (GymMachine[] memory allMachines)
    {
        allMachines = new GymMachine[](machineNames.length);
        for (uint i = 0; i < machineNames.length; i++) {
            allMachines[i] = machines[machineNames[i]];
        }
    }
}

contract GymVoting is GymMachineManager {
    // Event
    event Voted(address indexed voter, string machine);

    // Struct
    struct Voter {
        bool hasVoted;
        string votedMachine;
    }

    // State variables
    uint public endVoting;
    mapping(address => Voter) public voters;

    modifier votingActive() {
        require(block.timestamp <= endVoting, "Voting has ended.");
        _;
    }

    constructor(uint votingDuration) {
        endVoting = block.timestamp + votingDuration;
    }

    function setEndVoting() public onlyManager {
        endVoting = block.timestamp;
    }

    function vote(string calldata machineName) public votingActive {
        require(!voters[msg.sender].hasVoted, "Voter has already voted.");
        require(
            machines[machineName].state == MachineState.Active,
            "This machine is not available for voting."
        );

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedMachine = machineName;
        machines[machineName].voteCount += 1;

        emit Voted(msg.sender, machineName);
    }

    function getMostUsedMachine()
        public
        view
        returns (string memory mostUsedMachine)
    {
        uint highestVotes = 0;
        for (uint i = 0; i < machineNames.length; i++) {
            string memory name = machineNames[i];
            if (machines[name].voteCount > highestVotes) {
                highestVotes = machines[name].voteCount;
                mostUsedMachine = name;
            }
        }
        return mostUsedMachine;
    }

    // Pure function example (not directly related to the voting logic)
    function calculatePercentage(
        uint voteCount,
        uint totalVotes
    ) public pure returns (uint percentage) {
        return (voteCount * 100) / totalVotes;
    }
}
