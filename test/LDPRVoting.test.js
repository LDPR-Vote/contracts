// test/LDPRVoting.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LDPR Voting with SBT", function () {
  let sbt, voting, owner, alice, bob;

  beforeEach(async () => {
    [owner, alice, bob] = await ethers.getSigners();

    const SBT = await ethers.getContractFactory("IdentitySBT");
    sbt = await SBT.deploy();
    await sbt.waitForDeployment();

    const Voting = await ethers.getContractFactory("LDPRVoting");
    voting = await Voting.deploy(await sbt.getAddress());
    await voting.waitForDeployment();

    // минтим SBT для alice
    await sbt.connect(owner).issue(alice.address);
  });

  it("should reject issue by non-owner", async () => {
    await expect(sbt.connect(alice).issue(bob.address)).to.be.revertedWith("Not owner");
  });

  it("should reject already issued", async () => {
    await expect(sbt.connect(owner).issue(alice.address)).to.be.revertedWith("Already verified");
  });

  it("should reject transfer", async () => {
    await expect(sbt.connect(alice).transferFrom(alice.address, bob.address, 1)).to.be.revertedWith("Soulbound: non-transferable");
  });

  it("should reject create by non-owner", async () => {
    await expect(voting.connect(alice).createVote("Вы за свободу?", ["Да", "Нет"], 3600)).to.be.revertedWith("Not owner");
  });

  it("should return vote data", async () => {
    await voting.connect(owner).createVote("Вы за свободу?", ["Да", "Нет"], 3600);
    const vote = await voting.getVote(1);
    expect(vote.question).to.equal("Вы за свободу?");
    expect(vote.options).to.deep.equal(["Да", "Нет"]);
    expect(vote.endTime - vote.startTime).to.equal(3600);
  });

  it("should allow verified user to vote", async () => {
    await voting.connect(owner).createVote("Вы за мир?", ["Да", "Нет"], 3600);
    await voting.connect(alice).vote(1, 0); // голос "Да"

    const results = await voting.getResults(1).catch(() => null);
    expect(results).to.equal(null); // голосование ещё не закончилось
  });

  it("should reject unverified users", async () => {
    await voting.connect(owner).createVote("Вы за свободу?", ["Да", "Нет"], 3600);
    await expect(voting.connect(bob).vote(1, 1)).to.be.revertedWith("Not verified (no SBT)");
  });

  it("should count votes correctly", async () => {
    await voting.connect(owner).createVote("LDPR рулит?", ["Да", "Нет"], 1);

    await voting.connect(alice).vote(1, 0);
    await ethers.provider.send("evm_increaseTime", [2]); // время вперёд
    await ethers.provider.send("evm_mine", []);

    const results = await voting.getResults(1);
    expect(results[0]).to.equal(1);
    expect(results[1]).to.equal(0);
  });
});
