// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract GymMachineVoting {
    // Events
    event GymMachineAdded(string name);
    event Voted(address indexed voter, string machine);
    event MachineStateUpdated(string machine, MachineState state);

    // Enums and States
    enum MachineState {
        Active,
        Inactive
    }

    // Structs
    struct GymMachine {
        string name;
        uint voteCount;
        MachineState state;
    }

    struct Voter {
        bool hasVoted;
        string votedMachine;
    }

    // State variables
    address public manager;
    uint public endVoting;

    mapping(string => GymMachine) public machines;
    string[] public machineNames; // Array to store machine names

    mapping(address => Voter) public voters;

    // Modifiers
    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Unauthorized: Only manager can perform this action."
        );
        _;
    }

    modifier votingActive() {
        require(block.timestamp <= endVoting, "Voting has ended.");
        _;
    }

    // Constructor to initialize the manager and voting period.
    constructor(uint votingDuration) {
        manager = msg.sender;
        endVoting = block.timestamp + votingDuration;
    }

    // External functions
    function addMachine(string calldata name) external onlyManager {
        require(machines[name].voteCount == 0, "Machine already exists.");
        machines[name] = GymMachine({
            name: name,
            voteCount: 0,
            state: MachineState.Active
        });
        machineNames.push(name); // Add name to the array
        emit GymMachineAdded(name);
    }

    function vote(string calldata machineName) external votingActive {
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

    function updateMachineState(
        string calldata machineName,
        MachineState state
    ) external onlyManager {
        require(machines[machineName].voteCount > 0, "Machine does not exist.");
        machines[machineName].state = state;

        emit MachineStateUpdated(machineName, state);
    }

    // View functions
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
