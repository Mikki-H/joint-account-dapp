// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract JointAccountDApp {
    struct User {
        uint256 id;
        string name;
        bool exists;
    }
    
    struct Account {
        uint256 user1Balance;
        uint256 user2Balance;
    }
    
    mapping(uint256 => User) public users;
    mapping(uint256 => mapping(uint256 => Account)) public jointAccounts;
    mapping(uint256 => uint256[]) public userConnections;
    
    uint256 private constant MAX_USERS = 1000;
    
    // Events
    event UserRegistered(uint256 id, string name);
    event AccountCreated(uint256 user1, uint256 user2, uint256 balance);
    event AccountClosed(uint256 user1, uint256 user2);
    event AmountTransferred(uint256 fromUser, uint256 toUser, uint256 amount);
    event StateReset();
    
    // Register a new user
    function registerUser(uint256 id, string memory userName) public {
        require(!users[id].exists, "User already registered.");
        users[id] = User(id, userName, true);
        emit UserRegistered(id, userName);
    }
    
    // Check if a user exists
    function checkAccountExists(uint256 id) public view returns (bool) {
        return users[id].exists;
    }
    
    // Create a joint account between two users
    function createAcc(uint256 user1, uint256 user2, uint256 balance) public {
        require(users[user1].exists && users[user2].exists, "Users must exist.");
        
        // Exit early if the account already exists
        if (jointAccounts[user1][user2].user1Balance > 0) {
            return;
        }
        
        // Create a new account and initialize balances
        jointAccounts[user1][user2] = Account(balance / 2, balance / 2);
        jointAccounts[user2][user1] = Account(balance / 2, balance / 2);
        
        // Update user connections
        userConnections[user1].push(user2);
        userConnections[user2].push(user1);
        
        emit AccountCreated(user1, user2, balance);
    }

    
    // Internal function to remove a connection
    function removeConnection(uint256[] storage connections, uint256 target) internal {
        for (uint256 i = 0; i < connections.length; i++) {
            if (connections[i] == target) {
                connections[i] = connections[connections.length - 1];
                connections.pop();
                break;
            }
        }
    }
    
    // Close a joint account between two users
    function closeAccount(uint256 user1, uint256 user2) public {
        require(jointAccounts[user1][user2].user1Balance > 0, "No account exists.");
        delete jointAccounts[user1][user2];
        delete jointAccounts[user2][user1];
        removeConnection(userConnections[user1], user2);
        removeConnection(userConnections[user2], user1);
        emit AccountClosed(user1, user2);
    }
    
    // Find the shortest path using BFS
    function findShortestPath(uint256 start, uint256 end) internal view returns (uint256[] memory) {
        bool[] memory visited = new bool[](MAX_USERS);
        uint256[] memory parent = new uint256[](MAX_USERS);
        uint256[] memory queue = new uint256[](MAX_USERS);
        
        uint256 front = 0;
        uint256 rear = 0;
        
        // Initialize parent array
        for (uint256 i = 0; i < MAX_USERS; i++) {
            parent[i] = type(uint256).max;
        }
        
        // Start BFS
        queue[rear++] = start;
        visited[start] = true;
        
        bool pathFound = false;
        while (front < rear) {
            uint256 currentNode = queue[front++];
            
            if (currentNode == end) {
                pathFound = true;
                break;
            }
            
            for (uint256 i = 0; i < userConnections[currentNode].length; i++) {
                uint256 neighbor = userConnections[currentNode][i];
                if (!visited[neighbor]) {
                    visited[neighbor] = true;
                    parent[neighbor] = currentNode;
                    queue[rear++] = neighbor;
                }
            }
        }
        
        if (!pathFound) {
            uint256[] memory emptyPath;
            return emptyPath;
        }
        
        // Count path length
        uint256 pathLength = 1;
        uint256 current = end;
        while (current != start) {
            pathLength++;
            current = parent[current];
        }
        
        // Construct path
        uint256[] memory path = new uint256[](pathLength);
        current = end;
        for (uint256 i = pathLength - 1; i > 0; i--) {
            path[i] = current;
            current = parent[current];
        }
        path[0] = start;
        
        return path;
    }
    
    // Transfer amount between users along a valid path
    function sendAmount(uint256 fromUser, uint256 toUser, uint256 amount) public {
        require(users[fromUser].exists && users[toUser].exists, "Users must exist.");
        require(amount > 0, "Amount must be greater than 0.");
        
        uint256[] memory path = findShortestPath(fromUser, toUser);
        require(path.length > 0, "No valid path found between users.");
        
        // Verify sufficient balance along the path
        for (uint256 i = 0; i < path.length - 1; i++) {
            uint256 currentUser = path[i];
            uint256 nextUser = path[i + 1];
            require(
                jointAccounts[currentUser][nextUser].user1Balance >= amount,
                "Insufficient balance in path"
            );
        }
        
        // Transfer amount along the path
        for (uint256 i = 0; i < path.length - 1; i++) {
            uint256 currentUser = path[i];
            uint256 nextUser = path[i + 1];
            
            jointAccounts[currentUser][nextUser].user1Balance -= amount;
            jointAccounts[currentUser][nextUser].user2Balance += amount;
            
            // Update reverse mapping
            jointAccounts[nextUser][currentUser].user2Balance -= amount;
            jointAccounts[nextUser][currentUser].user1Balance += amount;
        }
        
        emit AmountTransferred(fromUser, toUser, amount);
    }
    
    // Reset the entire state (for testing only)
    function resetState() public {
        for (uint256 i = 0; i < MAX_USERS; i++) {
            if (users[i].exists) {
                delete users[i];
                uint256[] memory connections = userConnections[i];
                for (uint256 j = 0; j < connections.length; j++) {
                    uint256 connectedUser = connections[j];
                    delete jointAccounts[i][connectedUser];
                    delete jointAccounts[connectedUser][i];
                }
                delete userConnections[i];
            }
        }
        emit StateReset();
    }
}