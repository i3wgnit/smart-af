const fs = require('fs')
const Promise = require('bluebird')

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

Promise.promisifyAll(web3.eth)

let bfDeployContractData = `6020610113604039602061015360003960005161017360a0396000516081016060525b602051806000511460f657806001016020526081015160ff1680602b14606f5780602d1460845780603e1460995780603c1460a75780605b1460b55780605d1460bd57602e1460d5576022565b506060516001815160ff160190601f01536022565b506060516001815160ff160390601f01536022565b506001606051016060526022565b506001606051036060526022565b506020516022565b506060515160ff1660cd57506022565b806020526022565b6060515160ff16608051806001016080526040516000510160a00101536022565b6080516040516000510160a001a06080516040516000510160a001f3`

const abi = [{"inputs":[{"name":"len","type":"uint256"},{"name":"bf_code","type":"bytes"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]
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
