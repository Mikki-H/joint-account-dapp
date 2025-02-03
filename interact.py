from web3 import Web3
import json
import random
import matplotlib.pyplot as plt
import numpy as np

# Connect to local Ethereum node
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:7545'))  # Default Ganache port

# Load the contract ABI and address
with open('build/contracts/JointAccountDApp.json') as f:
    contract_json = json.load(f)
    contract_abi = contract_json['abi']

# Replace with actual contract address from migration output
contract_address = '0x5F516b3c4f0B4a495c6C455Fe92af68410a7E7EF'  # Replace with actual address
checksum_address = Web3.to_checksum_address(contract_address)

contract = w3.eth.contract(address=checksum_address, abi=contract_abi)

# Register 100 users
for i in range(1, 101):
    user_exists = contract.functions.users(i).call()[2]  # Check if user exists
    if not user_exists:
        tx_hash = contract.functions.registerUser(i, f'User{i}').transact({'from': w3.eth.accounts[0]})
        w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f"Registered User {i}")

# Create joint accounts and set balances
mean_balance = 10
for i in range(1, 101):
    for j in range(i + 1, 101):
        if random.random() < 0.1:  # Adjust probability to create a power-law distribution
            account_exists = contract.functions.jointAccounts(i, j).call()[0] > 0  # Check if account exists
            if not account_exists:
                balance = np.random.exponential(mean_balance)
                tx_hash = contract.functions.createAcc(i, j, int(balance)).transact({'from': w3.eth.accounts[0]})
                w3.eth.wait_for_transaction_receipt(tx_hash)
                print(f"Created joint account between User {i} and User {j} with initial balance {balance}")

# Perform transactions
success_count = 0
total_count = 0
success_ratios = []

for _ in range(1000):
    user1 = random.randint(1, 100)
    user2 = random.randint(1, 100)
    if user1 != user2:
        try:
            balance = contract.functions.jointAccounts(user1, user2).call()[0]
            print(f"Attempting transaction from User {user1} to User {user2} with balance {balance}")
            if 1 <= balance:
                tx_hash = contract.functions.sendAmount(user1, user2, 1).transact({'from': w3.eth.accounts[0]})
                w3.eth.wait_for_transaction_receipt(tx_hash)
                success_count += 1
                print(f"Transaction successful from User {user1} to User {user2}")
            else:
                print(f"Insufficient balance for transaction from User {user1} to User {user2}")
        except Exception as e:
            print(f"Transaction failed from User {user1} to User {user2}: {e}")
        total_count += 1
        if total_count % 100 == 0:
            success_ratios.append(success_count / total_count)
            print(f"Success ratio after {total_count} transactions: {success_ratios[-1]}")

# Append the final success ratio
if total_count % 100 != 0:
    success_ratios.append(success_count / total_count)

# Plot the success ratios
plt.plot(range(100, 100 * (len(success_ratios) + 1), 100), success_ratios)
plt.xlabel('Number of Transactions')
plt.ylabel('Success Ratio')
plt.title('Transaction Success Ratio Over Time')
plt.show()