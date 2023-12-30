import { ethers } from "hardhat";

async function main() {
  const BookRental = await ethers.getContractFactory('BookRental');
  const _rentalFactory = await BookRental.deploy();

  console.log(
    `Rental book factory deployed to ${_rentalFactory.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
