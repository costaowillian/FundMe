compile:; forge compile -vvvv

build:; forge build

run:; forge script script/DeployFundMe.s.sol

test:; forge test -vvvv

.PHONY: test compile build run
