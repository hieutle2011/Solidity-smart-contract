pragma solidity ^0.4.19;

import "./zombiefactory.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  // 1. Remove this:
  
  // 2. Change this to just a declaration:
  KittyInterface kittyContract;

  // 3. Add setKittyContractAddress method here
  function setKittyContractAddress(address _address) external onlyOwner {
      kittyContract = KittyInterface(_address);
  }

  // 1. Define `_triggerCooldown` function here
  function _triggerCooldown(Zombie storage _zombi) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  // 2. Define `_isReady` function here
  function _isReady(Zombie storage _zombie) internal view {
    return (_zombie.readyTime <= now);
  }
  
  // change function from public to internal so that it is more secure
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
    // add a check for _isReady here
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(_species) == keccak256("kitty")) {
      newDna = newDna - newDna % 100 + 99;
    }
    _createZombie("NoName", newDna);
    // add a trigger for cooldown
    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}
