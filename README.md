# Quantum-Key-Distribution-BB84
This is a Q# implementation of the BB84 protocol, which is a quantum-based key distribution protocol. Once the keys are exchanged they are used as a OneTimePad to encrypt a message and send it between Alice and Bob. Q# is a quantum simulator which we use to simulate entangled particles and basis to observe the "spin" of each charged proton. 

# Process
1. Prepare the qubits (Alice’s operation selects a random bit value and a random basis for encoding)
2. Receive qubits (Bob’s operation selects random basis and measures the qubit)
3. Calculate the sifted key and use it to encrypt a “hello quantum world” message(Alice & Bob communicate via a classical channel,exchange basis values, and discard the measurements where the bases did not match, encrypt/exchange/decrypt a “hello quantum world” message between Alice & Bob)
4. Introduce an evesdropper (Eve randomly selects a basis and measures the qubit before sending the qubit along to Bob). Your Eve operation should log/output the basis & measurements. NOTE: If Eve were to share basis choices with Alice or Bob, they would effectively form a sifted key between Eve & the other party. That said, MITM is meant to stay hidden, so EVve would just relay the qubits without telling Alice/Bob.
5. Detect the MITM attack (the sifted key does not allow encryption/decryption).

# Installation
```
$ sudo apt update
$ sudo apt install software-properties-common apt-transport-https
$ wget -qO-https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
$ sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
$ sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
$ sudo apt install code
$ wget https://packages.microsoft.com/config/ubuntu/20.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
$ sudo dpkg -i packages-microsoft-prod.deb
$sudo apt install -y apt-transport-https
$sudo apt install -y dotnet-sdk-3.1
$ sudo apt install -y dotnet-sdk-5.0
$ sudo apt update

Once VSCode & the SDK are installed, open it on your VM and manually add the Microsoft Quantum Development Kit

$ pip3 install onetimepad
$ conda create -n qsharp-env -c quantum-engineering qsharp notebook
$ conda activate qsharp-env
```

# How to Run
The Python script will call the .qs program which will first conduct the quantum key exchange and then return Bob and Alice's private keys, which will be used in the python script to encrypt a message using OneTimePad to send between each other. You can also adjust Line 18 of the Program.qs script from RunBB84Protocol(32, 0.0) -> RunBB84Protocol(32, 1.0) which will change the probability that qubits are being intercepted. 

`python3 run.py`

# Resources
`https://www.strathweb.com/2020/10/introduction-to-quantum-computing-with-q-part-9-bb84-quantum-key-distribution/`

`https://docs.microsoft.com/en-us/azure/quantum/install-python-qdk?tabs=tabid-conda`
