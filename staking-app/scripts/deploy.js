const hre = require("hardhat");

async function main() {
  const accounts = await ethers.getSigners();
  // console.log(accounts);
  const account = accounts[1];
  console.log(account);

  const TokenUSDT = await hre.ethers.getContractFactory("TokenUSDT");
  const TokenNEW = await hre.ethers.getContractFactory("TokenNEW");
  const Staking = await hre.ethers.getContractFactory("Staking");

  const tokenUSDT = await TokenUSDT.connect(account).deploy();
  await tokenUSDT.deployed();
  console.log(`TokenUSDT contract was deployed to ${tokenUSDT.address}`);

  const tokenNEW = await TokenNEW.connect(account).deploy();
  await tokenNEW.deployed();
  console.log(`TokenNEW contract was deployed to ${tokenNEW.address}`);

  const staking = await Staking.connect(account).deploy(tokenNEW.address, tokenUSDT.address);
  await staking.deployed();
  console.log(`Staking contract was deployed to ${staking.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
