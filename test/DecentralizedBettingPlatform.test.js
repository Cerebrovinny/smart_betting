const DecentralizedBettingPlatform = artifacts.require("DecentralizedBettingPlatform");

contract("DecentralizedBettingPlatform", (accounts) => {
  let instance;

  beforeEach(async () => {
    instance = await DecentralizedBettingPlatform.new();

    // Set initial user balance
    const initialBalance = web3.utils.toWei("1", "ether");
    await instance.deposit({ from: accounts[0], value: initialBalance });
  });

  it("should allow users to place bets", async () => {
    const amount = web3.utils.toWei("0.1", "ether");
    const result = true;
    const testAccount = accounts[1];
  
    await instance.deposit({ from: testAccount, value: amount });
  
    const userBalanceBefore = await instance.balances(testAccount);
    await instance.placeBet(result, { from: testAccount, value: amount });
    const userBalanceAfter = await instance.balances(testAccount);
  
    assert.equal(userBalanceBefore - amount, userBalanceAfter, "Bet amount was not subtracted from user's balance");
  });

  it("should allow users to withdraw their winnings", async () => {
    const amount = web3.utils.toWei("0.1", "ether");
    const result = true;
    const testAccount = accounts[0];
  
    const userBalanceBefore = await instance.balances(testAccount);
    console.log("UserBalanceBefore:", userBalanceBefore);
  
    await instance.placeBet(result, { from: testAccount, value: amount });
  
    // Add a losing bet
    await instance.deposit({ from: accounts[2], value: amount });
    await instance.placeBet(!result, { from: accounts[2], value: amount });
  
    const contractBalanceBefore = await web3.eth.getBalance(instance.address);
    console.log("ContractBalanceBefore:", contractBalanceBefore);
  
    await instance.distributeWinnings(result, { from: testAccount });
  
    const contractBalanceAfter = await web3.eth.getBalance(instance.address);
    console.log("ContractBalanceAfter:", contractBalanceAfter);
  
    const fee = (amount * 5) / 100;
    console.log("Fee:", fee);
  
    assert.equal(contractBalanceAfter - contractBalanceBefore, amount - fee, "Contract balance was not updated correctly");
    assert.equal(await instance.totalVotes(), 0, "Total votes were not reset");
    assert.equal(await instance.isLocked(), true, "Contract was not locked");
  
    const userBalanceAfter = await instance.balances(testAccount);
    console.log("UserBalanceAfter:", userBalanceAfter);
  
    assert.equal(userBalanceAfter - userBalanceBefore, amount * 2, "User did not receive winnings");
  });
  
  
});
