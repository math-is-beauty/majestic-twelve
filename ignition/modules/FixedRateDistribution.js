
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("FixedRateDistribution", (m) => {
    const distribution = m.contract("FixedRateDistribution", [
        "0x0D5E61957b30F9DC4C7cDE4e9B9F8fb57FFA777b",
        false,
        10 ** 4
    ]);

    // console.log(`Cupcake vending machine deployed to ${vendingMachine}`, vendingMachine);
    // const apollo = m.contract("Rocket", ["Saturn V"]);
  
    // m.call(apollo, "launch", []);
  
    // return { apollo };
});
