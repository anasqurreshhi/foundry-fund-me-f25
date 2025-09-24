// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {FoundryZkSyncChecker} from "lib/foundry-devops/src/FoundryZkSyncChecker.sol";

contract ZkSyncDevOps is Test, ZkSyncChainChecker, FoundryZkSyncChecker {
    // Remove the `skipZkSync`, then run `forge test --mt testZkSyncChainFails --zksync` and this will fail!
    function testZkSyncChainFails() public skipZkSync {
        address ripemd = address(uint160(3));

        bool success;
        // Don't worry about what this "assembly" thing is for now
        assembly {
            success := call(gas(), ripemd, 0, 0, 0, 0, 0)
        }
        assert(success);
    }

    // You'll need `ffi=true` in your foundry.toml to run this test
    // // Remove the `onlyVanillaFoundry`, then run `foundryup-zksync` and then
    // // `forge test --mt testZkSyncFoundryFails --zksync`
    // // and this will fail!
    function testZkSyncFoundryFails() public onlyVanillaFoundry {
        bool exists = vm.keyExistsJson('{"hi": "true"}', ".hi");
        assert(exists);
    }

    // certain tests only work on zksync foundry and not on vanilla foundry and vice versa.
    // you can use "only" or "skip" keyword to check the test if it only works on provided network,
    // e.g: onlyZksyncfoundry will work only for zkfoundry and only vanillafoundry will work on vfoundry
    // and can also use skipzksync like keywords to skip test if it is on zksync.
}
