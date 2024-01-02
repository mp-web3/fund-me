# Makefile already setted up https://github.com/Cyfrin/foundry-fund-me-f23/blob/main/Makefile
#YouTube tutorial https://www.youtube.com/watch?v=Q3tvdSrm2vI&list=PL2-Nvp2Kn0FPH2xU3IbKrrkae-VVXs1vk&index=100

-include .env

#.PHONY tells makefile what is not a folder
.PHONY: update anvil deploy

deploy-sepolia:; forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(BURNER2_PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv


DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

update:; forge update

anvil:;  anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

deploy:; forge script script/DeployStuff.s.sol:DeployStuff --broadcast --rpc-url http://localhost:8545  --private-key $(DEFAULT_ANVIL_KEY)   -vvvv 

interact:; forge script script/InteractWithStuff.s.sol:InteractWithStuff --broadcast --rpc-url http://localhost:8545  --private-key $(DEFAULT_ANVIL_KEY)   -vvvv 