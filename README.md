<p align="center"><img src="/logo.gif" align="center" width="200"></p>
<h1 align="center">Repay protcol</h1>
<p align="center">An abstraction layer on top of existing DeFi protocols to add meta transaction capabilites</p>

## Motivation

UX is major challenge while on-boading new users to DeFi, Managing different accounts on different chains, keep track of portfolio and keeping enough gas to make tranactions. However, there are exisiting solutions but they lack one or the other metrics and hence end user has to put more efforts. Imagine paying monthly gas bills of your usage and using single platform (contract owned by you!) to interact with any major DeFi protocol with more saftey.

We are aiming to solve following problems:

- Constant need to keep base currency to use as gas.
- Protection against frontrunning and sandwitch attacks.
- Allowing paying fees in erc20 which you are swapping/borrowing/lending
- Incentivize paying gas-usage bills on time.
- Potential protocol to be used by other protocols for reputation measurement.
- Adding meta-transaction capabilites to non EIP2771 (GSN) compliant contracts.

## How we built it

After not being convinced with our intial ideas and attempts during hackathon, we came across **EIP725** and did extensive research and brainstorming, we came with idea to build solution for top DeFi protocols to make them GSN compatible via proxy as thier native implemenation does not support it.

We used JS, soldity, hardhat, hardhat-deploy, hardhat tasks, uniswap interface, GSN contracts, infura, subgraph and IPFS for building this awesome project.

## Proposed Solution

<h4 align="center">Repay protcol</h4>

![current](https://user-images.githubusercontent.com/54898623/124495339-9f944900-ddd5-11eb-9b25-ba1e00e80654.png)

We decided to go for individual proxy per protocol per user to test out the idea and how it fits the space, also allowing having same function signature as parent DeFi protocol to being cross compatible with existing UI of protocols.

## INFO

Rinkeby Deployments (Uniswap):

- WhitelistPaymaster: https://rinkeby.etherscan.io/address/0x7c5077876533ae371608dA9B86cfb794302DBEA0
- InteractionProxyDeployer: https://rinkeby.etherscan.io/address/0x32C624D907A8F4446a1A6d40F97219D0F13FE044
- UniswapInteractionProxy: https://rinkeby.etherscan.io/address/0xa98c30869baab8454085aa445b0233353c58fb3b
- Subgraph:

Polygon Deployments (Quickswap):

- WhitelistPaymaster: https://polygonscan.com/address/0x62b1ed27e4d83d000138aac8cc9af1a6a058f760
- InteractionProxyDeployer: https://polygonscan.com/address/0xBd722D00Ea739b0F762CFA6c9E423457FEf0B4C7
- UniswapInteractionProxy: https://polygonscan.com/address/0x7cfb10284b928dc6ddd421d02b7a8034fdc4a8ff
- Subgraph:

## TODO

- extensive automated testing
- fronted for current imeplemenation for current uniswap proxy
- researching more about parsing msg.data to allow dynamic calls to any address
- security tests and gas optimizations

## Long Term Vision

![final_erc725](https://user-images.githubusercontent.com/54898623/124495214-770c4f00-ddd5-11eb-9a4e-2543751e6e28.png)

End goal is to eliminate need for designing implementation for each protocol and design erc725 based proxy to dynamically interact with any allowed receiver address. This will allow more flexiblity and less overhead. Explore more into usage of protcol and proper incentive mechanisms.

## PROS and CONS of current implementation vs long term vision

- Current state of project requires to imeplement proxy wrapper in order to allow GSN while long term vision would need single (or two) proxies per user to interact with any whitelisted protocol
- In long term, project will be much more practical and usable with negliglibe gas overhead while current overhead is about 13-20% on each transaction (however this is not issue on L2 or any over subsidized blockchains)
- currently end user's wallet is custodial of funds while moving it proxy will in long term to remove need for back and forth transfer and making pull based system, where user can transfer from proxy to EOA when required allowing for more composability.

## Special Credits

- OpenGSN team (help on discord during hackathon)
- GSN's public relayer's on polygon and rinkeby
- Uniswap team (help on discord during hackathon)
- EIP725 and EIP2771 proposers and authors
