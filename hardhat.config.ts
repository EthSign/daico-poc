import '@nomicfoundation/hardhat-toolbox'
import 'hardhat-storage-layout'
import 'hardhat-contract-sizer'
import 'hardhat-deploy'
import {config} from 'dotenv'

if (process.env.NODE_ENV !== 'PRODUCTION') {
    config()
}

export default {
    contractSizer: {
        strict: true
    },
    networks: {
        hardhat: {
            chainId: 33133,
            allowUnlimitedContractSize: false,
            loggingEnabled: false
        },
        local: {
            url: 'http://localhost:8545',
            chainId: 33133,
            allowUnlimitedContractSize: false,
            loggingEnabled: true
        },
        polygonMumbai: {
            url: 'https://rpc.ankr.com/polygon_mumbai',
            chainId: 80001,
            loggingEnabled: true,
            accounts: [process.env.PRIVATE_KEY],
            saveDeployments: true,
            zksync: false
        },
        sepolia: {
            chainId: 11155111,
            url: 'https://eth-sepolia.g.alchemy.com/v2/irTlUXcBaYDlCFNi9dHbjUxzm1pIfWbt',
            accounts: [process.env.PRIVATE_KEY],
            saveDeployments: true
        }
    },
    solidity: {
        compilers: [
            {
                version: '0.8.20',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                }
            }
        ]
    },
    namedAccounts: {
        deployer: {
            default: 0
        }
    },
    etherscan: {
        apiKey: {
            sepolia: process.env.ETHERSCAN_KEY,
            polygonMumbai: process.env.POLYGONSCAN_KEY
        }
    }
}
