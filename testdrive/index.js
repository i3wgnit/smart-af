const fs = require('fs')
const Promise = require('bluebird')

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

Promise.promisifyAll(web3.eth)

let bfDeployContractData = fs.readFileSync('./build/bfDeploy.bin', 'utf8')

bfDeployContractData = bfDeployContractData.trim()

const abi = require('./build/bfDeploy')
const bfDeploy = web3.eth.contract(abi)

const getBytecode = async (hash) => (await web3.eth.getTransactionReceiptAsync(hash))

function NewBfDeploy (tapeLen, bfCode, from, value, data) {
  return new Promise((resolve, reject) => {
      bfDeploy.new(tapeLen, bfCode, {
        data,
        from,
        gas: 1e6,
        value
      }, (err, contract) => {
        if (err) {
          reject(err)
          return
        }

        if (!contract.address) return

        resolve(contract)
      })
  });
}

async function run () {
  const accounts = await web3.eth.getAccountsAsync()

  const from = accounts[8]

  const args = [20, '++.']

  const bfContract = await NewBfDeploy(...args, from, 0, bfDeployContractData)

  Promise.promisifyAll(bfContract)

  console.log(await getBytecode(bfContract.transactionHash))
}

run()
