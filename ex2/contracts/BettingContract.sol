pragma solidity ^0.4.15;

contract BettingContract {
	/* Standard state variables */
	address owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes; 
	bool public gambASet = false;
	bool public gambBSet = false;


	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}


	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {
		if (msg.sender != owner) {
			revert();
		}

		_;
	}
	modifier OracleOnly() {
		if (msg.sender != oracle) {
			revert();
		}

		_;
	}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
		owner = msg.sender;
		outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		oracle = _oracle;
		return oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		if (msg.sender == owner) {
			revert();
		}
		
		if (!gambASet) {
			gamblerA = msg.sender;
			gambASet = true;
			bets[gamblerA] =  Bet(_outcome, msg.value, true);


			// betA = new Bet(_outcome, msg.value, true);
			BetMade(gamblerA);
		} else if (!gambBSet) {
			gamblerB = msg.sender;
			gambBSet = true;
			bets[gamblerA] =  Bet(_outcome, msg.value, true);

			// betB = new Bet(_outcome, msg.value, true);
			BetMade(gamblerB);
			BetClosed();
		} else {
			return false;
		}
		// bets[msg.sender] += _outcome;

		return true;
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
		if(bets[gamblerA].amount == _outcome && bets[gamblerB].amount == _outcome) {
			winnings[gamblerA] = bets[gamblerA].amount;
			winnings[gamblerB] = bets[gamblerB].amount;
		} else if (bets[gamblerA].amount == _outcome) {
			winnings[gamblerA] = bets[gamblerA].amount + bets[gamblerB].amount;
		} else if (bets[gamblerB].amount == _outcome) {
			winnings[gamblerB] = bets[gamblerA].amount + bets[gamblerB].amount;
		} else {
			winnings[oracle] = bets[gamblerA].amount + bets[gamblerB].amount;
		}
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		if (winnings[msg.sender] >= withdrawAmount) {
			winnings[msg.sender] = winnings[msg.sender] - withdrawAmount;
			msg.sender.transfer(withdrawAmount);
			return winnings[msg.sender];
		}
		return winnings[msg.sender];
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
		return outcomes;
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
		return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
	}

	/* Fallback function */
	function() {
		revert();
	}
}
