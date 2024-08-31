
const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("FlatCustomERC20", (m) => {
    const erc20 = m.contract("CustomERC20", ["Space Bucks", "SB", 18]);

    // console.log(`Cupcake vending machine deployed to ${vendingMachine}`, vendingMachine);
    // const apollo = m.contract("Rocket", ["Saturn V"]);
  
    // m.call(apollo, "launch", []);
  
    // return { apollo };
});
