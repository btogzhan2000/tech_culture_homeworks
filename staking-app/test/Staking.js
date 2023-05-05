const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Staking", function () {

  async function deployStakingFixture() {

    // Contracts are deployed using the first signer/account by default
    const [owner, account] = await ethers.getSigners();

    const TokenUSDT = await hre.ethers.getContractFactory("TokenUSDT");
    const TokenNEW = await hre.ethers.getContractFactory("TokenNEW");
    const Staking = await hre.ethers.getContractFactory("Staking");

    const tokenUSDT = await TokenUSDT.connect(owner).deploy();
    await tokenUSDT.deployed();
    // console.log(`TokenUSDT contract was deployed to ${tokenUSDT.address}`);

    const tokenNEW = await TokenNEW.connect(owner).deploy();
    await tokenNEW.deployed();
    // console.log(`TokenNEW contract was deployed to ${tokenNEW.address}`);

    const staking = await Staking.connect(owner).deploy(tokenNEW.address, tokenUSDT.address);
    await staking.deployed();
    // console.log(`Staking contract was deployed to ${staking.address}`);

    // grant minter role to staking contract
    await tokenNEW.connect(owner).grantRole(tokenNEW.MINTER_ROLE(), staking.address);
    // mint tokens to staking contract, it will need them to give out rewards
    await tokenNEW.connect(owner).mint(staking.address, 100);
    await tokenUSDT.connect(owner).mint(account.address, 100);

    return { tokenUSDT, tokenNEW, staking, owner, account };
  }

  it("buy token test", async function () {
    const { tokenUSDT, tokenNEW, staking, owner, account } = await loadFixture(deployStakingFixture);

    const init_usdt_balance_account = await tokenUSDT.balanceOf(account.address);
    // approve contract to spend token_usdt of account
    await tokenUSDT.connect(account).approve(staking.address, 10);
    await staking.connect(account).buyToken(10);

    expect(await tokenNEW.balanceOf(account.address)).to.equal(10);
    expect(await tokenUSDT.balanceOf(staking.address)).to.equal(10);
    expect(await tokenUSDT.balanceOf(account.address)).to.equal(init_usdt_balance_account - 10);
  });

  it("calculate reward test", async function () {
    const { tokenUSDT, tokenNEW, staking, owner, account } = await loadFixture(deployStakingFixture);

    const days_staked = 1;
    const interest_rate = 20;
    const staked_balance = 10;
    const expected_reward = days_staked  * staked_balance *  interest_rate / 100;

    expect(await staking.connect(account).calculateReward(days_staked, staked_balance, interest_rate)).to.equal(expected_reward);
  });

  it("claim test", async function () {
    const { tokenUSDT, tokenNEW, staking, owner, account } = await loadFixture(deployStakingFixture);

    const days_staked = 0;
    const interest_rate = 20;
    const staked_balance = 10;

    await tokenUSDT.connect(account).approve(staking.address, 10);
    await staking.connect(account).buyToken(10);

    await staking.connect(account).claim();
    var expected_reward = await staking.connect(account).calculateReward(days_staked, staked_balance, interest_rate);
    
    expect(await tokenNEW.balanceOf(account.address)).to.equal(expected_reward + 10);
  });

  it("withdraw test", async function () {
    const { tokenUSDT, tokenNEW, staking, owner, account } = await loadFixture(deployStakingFixture);

    const init_usdt_balance_account = await tokenUSDT.balanceOf(account.address)
    const init_new_balance_staking = await tokenNEW.balanceOf(staking.address)

    await tokenUSDT.connect(account).approve(staking.address, 10);
    await staking.connect(account).buyToken(10);

    await tokenNEW.connect(account).approve(staking.address, 10);

    await staking.connect(account).claim();
    await staking.connect(account).withdraw();
    expect(await tokenUSDT.balanceOf(account.address)).to.equal(parseInt(init_usdt_balance_account));
    expect(await tokenNEW.balanceOf(staking.address)).to.equal(parseInt(init_new_balance_staking) + 10);

  });
});

// there can be more tests, such as exception checking, etc


