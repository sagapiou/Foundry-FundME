-include .env

build:
	forge build

deploy-anvil:
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL_LOCAL) --broadcast --private-key $(PRIVATE_KEY_LOCAL) 

deploy-sepolia:
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_SEPOLIA) --private-key ${PRIVATE_KEY_SEPOLIA} --broadcast -vvvv

deploy-sepolia-verify:
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_SEPOLIA) --private-key $(PRIVATE_KEY_SEPOLIA) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
