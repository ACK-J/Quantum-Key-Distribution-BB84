import qsharp
from BB84 import Start
import onetimepad

success, aliceKey, BobKey = Start.simulate()

binaryKeyAlice = ""
binaryKeyBob = ""
for each in aliceKey:
    if each is True:
        binaryKeyAlice = binaryKeyAlice + "1"
    else:
        binaryKeyAlice = binaryKeyAlice + "0"

for each in BobKey:
    if each is True:
        binaryKeyBob = binaryKeyBob + "1"
    else:
        binaryKeyBob = binaryKeyBob + "0"


message = "hello quantum world"
cipher = onetimepad.encrypt(message, binaryKeyAlice)
print("Cipher Text: ", cipher)

# Decryption 
plaintext = onetimepad.decrypt(cipher, binaryKeyBob)
print(plaintext)