import { ethers, run, network } from 'hardhat';
import '@nomiclabs/hardhat-etherscan';

async function main() {
  const Community = await ethers.getContractFactory('Community');
  const community = await Community.deploy();
  await community.deployed();
  const deployedTransaction = await community.deployTransaction;
  await deployedTransaction.wait(6);

  console.log(`community deployed at ${community.address}`);

  //verify on etherscan only if it uses the network with chainid 5. wait 6 block confirmations before verifying
  if (network.config.chainId === 5) {
    await run('verify:verify', {
      address: community.address,
      contract: 'contracts/Community.sol:Community',
      constructorArgs: [],
    });
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
