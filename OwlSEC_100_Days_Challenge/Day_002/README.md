**Day** 002 / **Date** (2025-11-02)    
**What I Worked On**: did HTB Beginner Challenge 'Fawn', and Wrote an Incomplete, but Fully Functional Shell Script That Encrypts/Decrypts Pipes With Twofish and other GPG Ciphers   
**What I Completed**: HTB Fawn    
**Progress Vs Yesterday**: Another Day For 100 Days    
**Evidence**: See Attached Files    
**Next Steps**: More HTB, and Eventually Rewrite the project in a full language, probably node, perl or python, add server/client functionality for reverse shells, and full compatibility with cryptcat    

The goal of tfencrypt.sh was to bridge regular netcat with cryptcat.    

This method proved inefficient for Cryptcat because they seem to encrypt every 16 bytes as "blocks".    
Trying this in bash was extremely inefficient and took a long time to process even 3KB of data.    

Still, this version of the script, is functional as a file/pipe encryption wrapper. (trivial if you know gpg already)    

See the Comments in the Code for more Information...    
