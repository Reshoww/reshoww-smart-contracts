import { expect } from "chai";
import { ethers } from "hardhat";

describe("bookRentalFlow", async () => {
  const BookRental = await ethers.getContractFactory('BookRental');
  const _rentalFactory = await BookRental.deploy();

  expect(_rentalFactory.books('0x678')).to.eq(null);
});
